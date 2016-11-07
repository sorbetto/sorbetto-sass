import CSass
import Foundation
import PathKit
import Sorbetto

extension Path {
    var isSassFile: Bool {
        guard let ext = `extension` else {
            return false
        }

        return ext.compare("sass", options: .caseInsensitive) == .orderedSame || ext.compare("scss", options: .caseInsensitive) == .orderedSame
    }
}

public struct Sass: Plugin {
    public enum OutputStyle {
        case nested
        case expanded
        case compact
        case compressed

        var rawValue: Sass_Output_Style {
            switch self {
            case .nested:
                return SASS_STYLE_NESTED
            case .expanded:
                return SASS_STYLE_EXPANDED
            case .compact:
                return SASS_STYLE_COMPACT
            case .compressed:
                return SASS_STYLE_COMPRESSED
            }
        }
    }
    
    public enum Error: Swift.Error {
        case invalidSyntax(String)
    }

    public var outputStyle: OutputStyle
    public var precision: Int
    public var indent: String
    public var linefeed: String
    public var emitsSourceComments: Bool

    public init(outputStyle: OutputStyle = .nested, precision: Int = 5, indent: String = "  ", linefeed: String = "\n", emitsSourceComments: Bool = false) {
        self.outputStyle = outputStyle
        self.precision = precision
        self.indent = indent
        self.linefeed = linefeed
        self.emitsSourceComments = emitsSourceComments
    }

    public func run(site: Site) throws {
        for path in site.paths where path.isSassFile {
            guard let file = site[path] else {
                continue
            }

            let context = sass_make_file_context((site.source + path).absolute().description)
            defer { sass_delete_file_context(context) }

            let options = sass_file_context_get_options(context)
            sass_option_set_output_style(options, outputStyle.rawValue)
            sass_option_set_precision(options, Int32(precision))
            sass_option_set_source_comments(options, emitsSourceComments)

            sass_compile_file_context(context)

            if let errorCString = sass_context_get_error_message(context) {
                let error = String(cString: errorCString)
                throw Sass.Error.invalidSyntax(error)
            }

            let outputCString = sass_context_get_output_string(context)
            let output = String(cString: outputCString!)
            file.contents = output.data(using: .utf8)!

            let newFilename = path.lastComponentWithoutExtension + ".css"
            let newPath = path + ".." + newFilename
            site[newPath] = file
            site[path] = nil
        }
    }
}
