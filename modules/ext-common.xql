xquery version "3.1";

(:~
 : Shared extension functions for SSRQ.
 :)
module namespace pmf="http://www.tei-c.org/tei-simple/xquery/functions/tei-common";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";


declare function pmf:heading-number($div as node()*) {
    if ($div/parent::tei:div) then 
        string-join(
        (pmf:heading-number($div/parent::tei:div), count($div/preceding-sibling::tei:div) + 1),
         '.'
        )
    else
        count($div/preceding-sibling::tei:div) + 1
};

declare function pmf:expand-attributes($classSpec as node(), $attList) {
    let $refs := $classSpec//tei:attDef/@ident 

    (: if attribute has been changed or added directly in elementSpec, mark the ones "inherited" from classes as crossed-out :)
    let $atts := for $r in $refs return 
        if ($attList?($r)) then 
            <hi xmlns="http://www.tei-c.org/ns/1.0" rendition="strike-through">@{$r/string()}</hi> 
        else 
            '@' || $r
            
    let $classes := 
        for $c in $classSpec/tei:classes/tei:memberOf/@key[starts-with(., 'att.')]
            let $cS := root($c)//tei:classSpec[@ident=$c] 
            return (' (' , pmf:expand-attributes($cS, $attList) ,')' )
    return
    (<ref xmlns="http://www.tei-c.org/ns/1.0" target="ref/{$classSpec/@ident/string()}">
    {$classSpec/@ident/string()}</ref>, 
    ' (', 
    for $i at $pos in $atts 
        return 
            if ($pos > 1) then 
                (', ', $i) 
            else 
                $i
    , ')', $classes)
};


(: return a list of members of an attribute or model class :)
declare function pmf:expand-members($classSpec as node()) {
    let $root := root($classSpec)
    return
    (
        for $c in $root//tei:memberOf[@key=$classSpec/@ident]/ancestor::tei:classSpec
            let $class := $c/@ident
            order by $class
            return
            (<ref xmlns="http://www.tei-c.org/ns/1.0" target="ref/{$class}"> {$class/string()}</ref>, ' [ ', pmf:expand-class-members($root, $class), ' ] ')
        ,
        pmf:expand-class-members($root, $classSpec/@ident)      
    )
};

declare function pmf:expand-class-members($root, $ident) {
    for $c in $root//tei:memberOf[@key=$ident]/ancestor::tei:elementSpec
        let $i := $c/@ident
        order by $i
        return
                
        (<ref xmlns="http://www.tei-c.org/ns/1.0" target="ref/{$i}"> {$i/string()}</ref>, ' ')
};

declare function pmf:expand-usedBy($classSpec) {
    <ref-cell type="used-by" xmlns="http://www.tei-c.org/ns/1.0">
        {
        let $root := root($classSpec)  
        for $c in ($root//tei:classRef[@key=$classSpec/@ident]/(ancestor::tei:elementSpec | ancestor::tei:macroSpec))
            let $n := $c/@ident/string() 
            order by $n 
            return (<ref xmlns="http://www.tei-c.org/ns/1.0" target="ref/{$n}">{$n}</ref>, ' ')      
        }
    </ref-cell>
};

declare function pmf:expand-macro-usedBy($macroSpec) {
    <ref-cell type="used-by" xmlns="http://www.tei-c.org/ns/1.0">
        {
        let $root := root($macroSpec)  
            for $c in $root//tei:macroRef[@key=$macroSpec/@ident]/ancestor::tei:elementSpec
            let $n := $c/@ident/string() 
            order by $n 
            return (<ref xmlns="http://www.tei-c.org/ns/1.0" target="ref/{$n}">{$n}</ref>, ' ')      
        }
    </ref-cell>
};