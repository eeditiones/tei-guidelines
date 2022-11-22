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
import module namespace rutil="http://e-editiones.org/roaster/util";
import module namespace rapi="http://teipublisher.com/api/ref" at "ref.xql";
import module namespace o2japi="http://teipublisher.com/api/odd-to-json" at "odd2json.xql";
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

declare function api:ident-autocomplete($request as map(*)) {
    array {
        sort(doc($config:data-root || "/p5.xml")//(tei:elementSpec | tei:classSpec | tei:macroSpec | tei:attSpec | tei:dataSpec)/@ident/string())
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