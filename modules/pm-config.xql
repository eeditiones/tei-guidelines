
xquery version "3.1";

module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config";

import module namespace pm-tei-web="http://www.tei-c.org/pm/models/tei/web/module" at "../transform/tei-web-module.xql";
import module namespace pm-tei-print="http://www.tei-c.org/pm/models/tei/fo/module" at "../transform/tei-print-module.xql";
import module namespace pm-tei-latex="http://www.tei-c.org/pm/models/tei/latex/module" at "../transform/tei-latex-module.xql";
import module namespace pm-tei-epub="http://www.tei-c.org/pm/models/tei/epub/module" at "../transform/tei-epub-module.xql";
import module namespace pm-docx-tei="http://www.tei-c.org/pm/models/docx/tei/module" at "../transform/docx-tei-module.xql";

declare variable $pm-config:web-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "tei.odd" return pm-tei-web:transform($xml, $parameters)
    default return pm-tei-web:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:print-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "tei.odd" return pm-tei-print:transform($xml, $parameters)
    default return pm-tei-print:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:latex-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "tei.odd" return pm-tei-latex:transform($xml, $parameters)
    default return pm-tei-latex:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:epub-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "tei.odd" return pm-tei-epub:transform($xml, $parameters)
    default return pm-tei-epub:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:tei-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "docx.odd" return pm-docx-tei:transform($xml, $parameters)
    default return error(QName("http://www.tei-c.org/tei-simple/pm-config", "error"), "No default ODD found for output mode tei")
            
    
};
            
    