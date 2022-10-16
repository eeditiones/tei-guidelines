xquery version "3.1";

module namespace o2j="http://teipublisher.com/api/odd-to-json";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare function o2j:elementSpec($elements as element(tei:elementSpec)*, $identMap as map(*), 
    $modelMap as map(*), $attsMap as map(*)) {
    for $element in $elements
    let $content := o2j:contains-elements($element/tei:content, $identMap, $modelMap)
    return
        map {
            "name": $element/@ident/string(),
            "children": array {
                sort($content)
            },
            "attributes": array {
                o2j:attributes($element, $attsMap)
            },
            "completion": map {
                "detail": $element/tei:gloss[@xml:lang='en']/string(),
                "info": $element/tei:desc[@xml:lang='en']/string(),
                "type": "keyword"
            }
        }
};

declare function o2j:attributes($element as element(tei:elementSpec), $attsMap as map(*)) {
    let $attDefs := (
        o2j:contains-attributes($element/tei:attList/*),
        for $class in $element/tei:classes/tei:memberOf/@key
        return
            $attsMap?($class)
    )
    for $def in $attDefs
    order by $def/@ident
    return
        map {
            "name": $def/@ident/string(),
            "completion": map {
                "type": "property",
                "detail": $def/tei:gloss[@xml:lang="en"]/string(),
                "info": $def/tei:desc[@xml:lang='en']/string(),
                "apply": $def/@ident/string() || '=""'
            }
        }
};

declare function o2j:class-members($classes as xs:string*, $root as document-node()) {
    for $class in $classes
    return (
        $root//tei:elementSpec[tei:classes/tei:memberOf/@key = $class]/@ident/string(),
        (: $memberMap?($class)/self::tei:elementSpec, :)
        o2j:class-members($root//tei:classSpec[tei:classes/tei:memberOf[@key = $class]]/@ident, $root)
        (: o2j:class-members($memberMap?($class)/self::tei:classSpec, $root, $memberMap) :)
    )
};

declare function o2j:attribute-class-members($classSpecs as element(tei:classSpec)*, $root as document-node()) {
    for $class in $classSpecs
    return (
        o2j:contains-attributes($class/tei:attList/*),
        let $inheritedClasses := 
            for $key in $classSpecs/tei:classes/tei:memberOf/@key
            return
                $root//tei:classSpec[@ident = $key]
        return
            o2j:attribute-class-members($inheritedClasses, $root)
    )
};

declare function o2j:contains-attributes($attDefs as element()*) {
    for $attDef in $attDefs
    return
        typeswitch ($attDef)
            case element(tei:attDef) return
                $attDef
            case element(tei:attRef) return
                root($attDef)//tei:attDef[@ident=$attDef/@name/string()]
            default return
                o2j:contains-attributes($attDef/*)
};

declare function o2j:contains-elements($contents as element()*, $identMap as map(*), $memberMap as map(*)) {
    for $content in $contents
    return 
        typeswitch($content)
            case element(tei:elementRef) return
                $content/@key/string()
            case element(tei:classRef) return
                $memberMap?($content/@key)
            case element(tei:macroRef) return
                let $macroSpec := $identMap?($content/@key)
                return
                    o2j:contains-elements($macroSpec/tei:content, $identMap, $memberMap)
            case element(tei:textNode) return
                ()
            case element() return
                o2j:contains-elements($content/*, $identMap, $memberMap)
            default return
                ()
};

declare function o2j:generate($request as map(*)) {
    let $start := $request?parameters?start
    let $odd := doc($config:data-root || "/p5.xml")
    let $identMap := map:merge(
        for $spec in $odd//(tei:elementSpec|tei:macroSpec)
        return
            map:entry($spec/@ident, $spec)
    )
    let $modelMap := map:merge(
        for $spec in $odd//tei:classSpec[@type = 'model']
        let $ident := $spec/@ident/string()
        return
            map:entry($ident, o2j:class-members($ident, $odd))
    )
    let $attributeMap := map:merge(
        for $spec in $odd//tei:classSpec[@type = 'atts']
        let $ident := $spec/@ident/string()
        return
            map:entry($ident, o2j:attribute-class-members($spec, $odd))
    )
    let $elements := $odd//tei:elementSpec
    return
        map {
            "elements": array {
                o2j:elementSpec($elements, $identMap, $modelMap, $attributeMap)
            }
        }
};
