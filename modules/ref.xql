xquery version "3.1";

module namespace rapi="http://teipublisher.com/api/ref";

import module namespace errors = "http://exist-db.org/xquery/router/errors";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config" at "pm-config.xql";
import module namespace tpu="http://www.tei-c.org/tei-publisher/util" at "lib/util.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function rapi:html($request as map(*)) {
    let $ref := xmldb:decode($request?parameters?id)
    return
        if ($ref) then
            let $xml := collection($config:data-root)//*[@ident=$ref]
            return
                if (exists($xml)) then
                    let $config := tpu:parse-pi(root($xml), ())
                    let $out := $pm-config:web-transform($xml, map { "root": $xml, "mode": "ref", "spec": "element", "lng": "en", "webcomponents": 7 }, $config?odd)
                    return $out
                else
                    error($errors:NOT_FOUND, "Specification for " || $ref || " not found")
        else
            error($errors:BAD_REQUEST, "No reference specified")
};