xquery version "3.1";

(:~
 : Non-standard extension functions, mainly used for the documentation.
 :)
module namespace pmf="http://www.tei-c.org/tei-simple/xquery/ext-html";

import module namespace html="http://www.tei-c.org/tei-simple/xquery/functions";

declare namespace tei="http://www.tei-c.org/ns/1.0";




declare function pmf:heading-number($config as map(*), $node as element(), $class as xs:string+, $content as node()*, $div as node()*) {
    if ($div/parent::tei:div) then 
        string-join(
        (pmf:heading-number($config, $node, $class, $content, $div/parent::tei:div), count($div/preceding-sibling::tei:div) + 1),
         '.'
        )
    else
        count($div/preceding-sibling::tei:div) + 1
};

declare function pmf:passthrough($config as map(*), $node as element(), $class as xs:string+, $content as node()*) {
    $config?apply-children($config, $node, $content)
};



