//
//  ViewController.swift
//  XMLModeler
//
//  Created by GeekXiaowei on 2017/12/11.

import UIKit

let xmlWithNamespace = """
<root xmlns:h=\"http://www.w3.org/TR/html4/\"
xmlns:f=\"http://www.w3schools.com/furniture\">
    <h:table>
        <h:tr>
            <h:td>Apples</h:td>
            <h:td>Bananas</h:td>
        </h:tr>
    </h:table>
    <f:table>
        <f:name>African Coffee Table</f:name>
        <f:width>80</f:width>
        <f:length>120</f:length>
    </f:table>
</root>
"""

let booksXML = """
<root>
    <books>
        <book>
            <title>Book A</title>
            <price>12.5</price>
            <year>2015</year>
        </book>
        <book>
            <title>Book B</title>
            <price>10</price>
            <year>1988</year>
        </book>
        <book>
            <title>Book C</title>
            <price>8.33</price>
            <year>1990</year>
            <amount>10</amount>
        </book>
    <books>
</root>
"""

class ViewController: UIViewController, XMLParserDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = XMLModel.parse(xmlfile: "data_5-23id")
        
    }
    
    
    
}

