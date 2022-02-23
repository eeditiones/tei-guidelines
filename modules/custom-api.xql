xquery version "3.1";

(:~
 : This is the place to import your own XQuery modules for either:
 :
 : 1. custom API request handling functions
 : 2. custom templating functions to be called from one of the HTML templates
 :)
module namespace api="http://teipublisher.com/api/custom";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Add your own module imports here :)
import module namespace rutil="http://exist-db.org/xquery/router/util";
import module namespace rapi="http://teipublisher.com/api/ref" at "ref.xql";
import module namespace app="teipublisher.com/app" at "app.xql";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare function api:idents($request as map(*)) {
    for $ident in doc($config:data-root || "/p5.xml")//(tei:elementSpec | tei:classSpec | tei:macroSpec | tei:attSpec | tei:dataSpec)/@ident
    return
        map {
            "ident": $ident/string(),
            "doc": "p5.xml",
            "title":
                if (matches($ident, "^(model|att)\..*$")) then
                    "TEI class " || $ident
                else
                    "TEI element " || $ident
        }
};

(:~
 : Keep this. This function does the actual lookup in the imported modules.
 :)
declare function api:lookup($name as xs:string, $arity as xs:integer) {
    try {
        function-lookup(xs:QName($name), $arity)
    } catch * {
        ()
    }
};