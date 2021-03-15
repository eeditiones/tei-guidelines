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

(: return a list of attributes per class, descend into other att classes :)
declare function pmf:expand-attributes($classSpec as node()) {
    let $refs := $classSpec//tei:attDef/@ident 
    let $atts := string-join(for $r in $refs return '@' || $r, ', ') 
    let $classes := 
        for $c in $classSpec/tei:classes/tei:memberOf/@key[starts-with(., 'att.')]
            let $cS := root($c)//tei:classSpec[@ident=$c] 
            return (' (' , pmf:expand-attributes($cS) ,')' )
            (: return $c/string() :)
    return
    (<ref xmlns="http://www.tei-c.org/ns/1.0" target="ref/{$classSpec/@ident/string()}"> {$classSpec/@ident/string()}</ref>, ' (', $atts, ')', $classes)
};

(: return a list of members of an attribute or model class :)
declare function pmf:expand-members($classSpec as node()) {
    for $c in root($classSpec)//tei:elementSpec[.//tei:memberOf[@key=$classSpec/@ident]]
        let $i := $c/@ident
        order by $i
        return
            
    (<ref xmlns="http://www.tei-c.org/ns/1.0" target="ref/{$i}"> {$i/string()}</ref>, ' ')
};