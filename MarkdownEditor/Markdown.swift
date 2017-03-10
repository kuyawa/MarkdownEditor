//
//  Markdown.swift
//  MarkdownEditor
//
//  Created by Mac Mini on 3/9/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Foundation


extension String {
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removeCR() -> String {
        return self.components(separatedBy: "\r\n").joined(separator: "\n")
    }
    
    func remove(_ pattern: String) -> String {
        guard self.characters.count > 0 else { return self }
        if let first = self.range(of: pattern, options: .regularExpression) {
            return self.replacingCharacters(in: first, with: "")
        }
        
        return self
    }
    
    func prepend(_ text: String) -> String {
        if text.isEmpty { return self }
        return text + self
    }
    
    func append(_ text: String) -> String {
        if text.isEmpty { return self }
        return self + text
    }
    
    func enclose(_ fence: (String, String)?) -> String {
        return (fence?.0 ?? " ") + self + (fence?.1 ?? " ")
    }
    
    func matches(_ pattern: String) -> Bool {
        guard self.characters.count > 0 else { return false }
        if let first = self.range(of: pattern, options: .regularExpression) {
            let match = self.substring(with: first)
            return !match.isEmpty
        }
        
        return false
    }
    
    func matchAndReplace(_ rex: String, _ rep: String, options: NSRegularExpression.Options? = []) -> String {
        if let regex = try? NSRegularExpression(pattern: rex, options: options!) {
            let range = NSRange(location: 0, length: self.characters.count)
            let mut = NSMutableString(string: self)
            _ = regex.replaceMatches(in: mut, options: [], range: range, withTemplate: rep)
            return String(describing: mut)
        } else {
            print("Regex not valid")
        }
        return self
    }
    
}


class Markdown {
    
    func parse(_ text: String) -> String {
        var md = text.removeCR()  // CR crashing linux
        
        md = cleanHtml(md)
        md = parseHeaders(md)
        md = parseBold(md)
        md = parseItalic(md)
        md = parseDeleted(md)
        md = parseImages(md)
        md = parseLinks(md)
        md = parseCodeBlock(md)
        md = parseCodeInline(md)
        md = parseHorizontalRule(md)
        md = parseUnorderedLists(md)
        md = parseOrderedLists(md)
        md = parseBlockquotes(md)
        md = parseYoutubeVideos(md)
        md = parseParagraphs(md)
        
        return md
    }
    
    func cleanHtml(_ md: String) -> String {
        return md.matchAndReplace("<.*?>", "")
    }
    
    func parseHeaders(_ md: String) -> String {
        var mx = md
        mx = mx.matchAndReplace("^###(.*)?", "<h3>$1</h3>", options: [.anchorsMatchLines])
        mx = mx.matchAndReplace("^##(.*)?", "<h2>$1</h2>", options: [.anchorsMatchLines])
        mx = mx.matchAndReplace("^#(.*)?", "<h1>$1</h1>", options: [.anchorsMatchLines])
        return mx
    }
    
    func parseBold(_ md: String) -> String {
        return md.matchAndReplace("\\*\\*(.*?)\\*\\*", "<b>$1</b>")
    }
    
    func parseItalic(_ md: String) -> String {
        return md.matchAndReplace("\\*(.*?)\\*", "<i>$1</i>")
    }
    
    func parseDeleted(_ md: String) -> String {
        return md.matchAndReplace("~~(.*?)~~", "<s>$1</s>")
    }
    
    func parseImages(_ md: String) -> String {
        var mx = md
        mx = mx.matchAndReplace("!\\[(\\d+)x(\\d+)\\]\\((.*?)\\)", "<img src=\"$3\" width=\"$1\" height=\"$2\" />")
        mx = mx.matchAndReplace("!\\[(.*?)\\]\\((.*?)\\)", "<img alt=\"$1\" src=\"$2\" />")
        return mx
    }
    
    func parseLinks(_ md: String) -> String {
        var mx = md
        mx = mx.matchAndReplace("\\[(.*?)\\]\\((.*?)\\)", "<a href=\"$2\">$1</a>")
        mx = mx.matchAndReplace("\\[http(.*?)\\]", "<a href=\"http$1\">http$1</a>")
        mx = mx.matchAndReplace("(^|\\s)http(.*?)(\\s|\\.\\s|\\.$|,|$)", "$1<a href=\"http$2\">http$2</a>$3 ", options: [.anchorsMatchLines])
        return mx
    }
    
    func parseCodeBlock(_ md: String) -> String {
        return md.matchAndReplace("```(.*?)```", "<pre>$1</pre>", options: [.dotMatchesLineSeparators])
        //parseBlock(&md, format: "^\\s{4}", blockEnclose: ("<pre>", "</pre>"))
    }
    
    func parseCodeInline(_ md: String) -> String {
        return md.matchAndReplace("`(.*?)`", "<code>$1</code>")
    }
    
    func parseHorizontalRule(_ md: String) -> String {
        return md.matchAndReplace("---", "<hr>")
    }
    
    func parseUnorderedLists(_ md: String) -> String {
        return parseBlock(md, format: "^\\*", blockEnclose: ("<ul>", "</ul>"), lineEnclose: ("<li>", "</li>"))
    }
    
    func parseOrderedLists(_ md: String) -> String {
        return parseBlock(md, format: "^\\d+[\\.|-]", blockEnclose: ("<ol>", "</ol>"), lineEnclose: ("<li>", "</li>"))
    }
    
    func parseBlockquotes(_ md: String) -> String {
        var mx = md
        mx = parseBlock(mx, format: "^>", blockEnclose: ("<blockquote>", "</blockquote>"))
        mx = parseBlock(mx, format: "^:", blockEnclose: ("<blockquote>", "</blockquote>"))
        return mx
    }
    
    func parseYoutubeVideos(_ md: String) -> String {
        return md.matchAndReplace("\\[youtube (.*?)\\]", "<p><a href=\"http://www.youtube.com/watch?v=$1\" target=\"_blank\"><img src=\"http://img.youtube.com/vi/$1/0.jpg\" alt=\"Youtube video\" width=\"240\" height=\"180\" /></a></p>")
    }
    
    func parseParagraphs(_ md: String) -> String {
        return md.matchAndReplace("\n\n([^\n]+)\n\n", "\n\n<p>$1</p>\n\n", options: [.dotMatchesLineSeparators])
    }
    
    func parseBlock(_ md: String, format: String, blockEnclose: (String, String), lineEnclose: (String, String)? = nil) -> String {
        let lines = md.components(separatedBy: .newlines)
        var result = [String]()
        var isBlock = false
        var isFirst = true
        
        for line in lines {
            var text = line
            if text.matches(format) {
                isBlock = true
                if isFirst { result.append(blockEnclose.0); isFirst = false }
                text = text.remove(format)
                text = text.trimmed().enclose(lineEnclose)
            } else if isBlock {
                isBlock = false
                isFirst = true
                text = text.append(blockEnclose.1+"\n")
            }
            result.append(text)
        }
        
        if isBlock { result.append(blockEnclose.1) } // close open blocks
        
        let mx = result.joined(separator: "\n")
        
        return mx
    }
    
}


// End
