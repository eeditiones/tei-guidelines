xquery version "3.1";

(:~
 : Non-standard extension functions, mainly used for the documentation.
 :)
module namespace pmf="http://www.tei-c.org/tei-simple/xquery/ext-html";

import module namespace html="http://www.tei-c.org/tei-simple/xquery/functions";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function pmf:expand-model($model as element()) {
    $model/@key/string(),
    for $parent in 
        root($model)//tei:classSpec[@ident=$model/@key]/tei:classes/tei:memberOf
    return
        pmf:expand-model($parent)
};

declare function pmf:contained-by($config as map(*), $node as element(), $class as xs:string+, $content as node()*) {
    let $refs := (
        for $class in $content/tei:memberOf[starts-with(@key, 'model.')] ! pmf:expand-model(.)
        let $macroSpec := root($content)//tei:macroSpec[tei:content//tei:classRef/@key = $class]
        return
            root($content)//tei:elementSpec[tei:content//tei:classRef/@key = $class] |
            root($content)//tei:elementSpec[tei:content//tei:macroRef/@key = $macroSpec/@ident],
        root($content)//tei:elementSpec[tei:content//tei:elementRef/@key = $content/@ident]
    )
    for $parents in $refs
    group by $module := $parents/@module
    order by $module
    return
        <div class="module">
            <h4>{$module/string()}</h4>:
            <ul>
            {
                for $parent in $parents
                let $ident := $parent/@ident/string()
                order by $ident
                return
                    <li><a href="ref/{$ident}">{$ident}</a></li>
            }
            </ul>
        </div>
};

declare function pmf:passthrough($config as map(*), $node as element(), $class as xs:string+, $content as node()*) {
    $config?apply-children($config, $node, $content)
};

declare function pmf:code($config as map(*), $node as element(), $class as xs:string+, $content as node()*, $lang as item()?) {
    <pb-code-highlight language="xml" theme="solarizedlight" class="{$class}">
        <template>{$content/node()}</template>
    </pb-code-highlight>
};


