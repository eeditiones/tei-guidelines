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