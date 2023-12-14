//
//  RCalcBinding.m
//  SwiftRPN
//
//  Created by Patrick Gelvin on 10/31/23.
//

#import <Foundation/Foundation.h>
#include "RCalcBinding.h"
#include "SwiftBackend.hpp"
#include "core/version.h"
#include "core/filter.h"
#include "app/help_text.h"

#include <algorithm>
#include <string>


RCalc::Application* UnwrapApplicationResult(RCalc::Result<RCalc::Application*> res) {
    return res.unwrap();
}


RCalc::Type RCalcTypeFromUInt8(uint8_t type) { return (RCalc::Type)type; }


void RCalcSubmitText(NSString* text) {
    std::string str { [text UTF8String] };
    RCalc::SwiftBackend::singleton.cb_submit_text(str);
}


NSString* GetVersionString() {
    return [[NSString alloc] initWithFormat:@"%s (%.6s)", VERSION_FULL_BUILD, VERSION_HASH];
}


namespace RCalc {

namespace Commands {

CommandMeta CMDMETA_SwiftRPN_ClearHist {
    "ClearHist",
    "Clears the history buffer.",
    {
    }
};

CommandMeta CMDMETA_SwiftRPN_Help {
    "Help",
    "Displays this help screen.",
    {
    }
};

CommandMeta CMDMETA_SwiftRPN_Queer {
    "Queer",
    "Toggles queer mode.",
    {
    }
};

CommandMeta CMDMETA_SwiftRPN_Settings {
    "Settings",
    "Displays the settings screen.",
    {
    }
};

std::vector<CommandMeta const *> SCOPECMDS_SwiftRPN {
    &CMDMETA_SwiftRPN_ClearHist,
    &CMDMETA_SwiftRPN_Help,
    &CMDMETA_SwiftRPN_Queer,
    &CMDMETA_SwiftRPN_Settings
};

ScopeMeta SCOPEMETA_SwiftRPN {
    "SwiftRPN",
    SCOPECMDS_SwiftRPN
};

}

struct SwiftRPNScope {};

template<>
void CommandMap<SwiftRPNScope>::activate() {
    _GlobalCommandMap::register_scope(Commands::SCOPEMETA_SwiftRPN);
}

}

void register_SwiftRPN_commands() {
    static RCalc::CommandMap<RCalc::SwiftRPNScope> map;
    map.activate();
}

NSArray<NSString*>* get_command_aliases(const std::vector<const char*>& aliases) {
    NSMutableArray<NSString*>* nsAliases = [[NSMutableArray<NSString*> alloc] init];
    
    for (const char* alias : aliases) {
        [nsAliases addObject:[[NSString alloc] initWithCString:alias encoding:NSUTF8StringEncoding]];
    }
    
    return nsAliases;
}


NSString* get_type_name(RCalc::Type type) {
    std::string type_name = RCalc::Value::get_type_name(type);
    return [[NSString alloc] initWithCString:type_name.c_str() encoding:NSUTF8StringEncoding];
}

NSArray<PreprocessedExample*>* preprocess_operator_examples(const RCalc::Operator& op) {
    static RCalc::RPNStack stack;
    
    NSMutableArray<PreprocessedExample*>* processedExamples = [[NSMutableArray<PreprocessedExample*> alloc] init];
    RCalc::OperatorMap& op_map = RCalc::OperatorMap::get_operator_map();
    
    for (const std::span<const char * const>& example_params : op.examples) {
        PreprocessedExample* processedExample = [[PreprocessedExample alloc] init];
        stack.clear();

        bool first = true;
        std::stringstream a11y;

        for (const char* param : example_params) {
            RCalc::Value value = RCalc::Value::parse(param).value();
            
            if (first) { first = false; } else {
                a11y << ", ";
            }
            a11y << "Input: " << get_accessibility_value(value);
            
            stack.push_item(RCalc::StackItem { create_displayables_from(value), std::move(value), false });
        }
        
        a11y << ". ";

        std::string op_name = RCalc::filter_name(op.name);
        RCalc::Result<std::optional<size_t>> err = op_map.evaluate(op_name, stack);

        if (!err) {
            RCalc::Logger::log_err("Cannot display example: %s", err.unwrap_err().get_message().c_str());
            continue;
        }

        first = true;
        std::stringstream ss;

        for (const RCalc::StackItem& item : stack.get_items()) {
            if (first) {
                first = false;
            }
            else {
                ss << ", ";
                a11y << ", ";
            }

            ss << item.result.to_string();
            a11y << "Result: " << get_accessibility_value(item.result);
        }
        
        a11y << ".";
        
        CowVec<RCalc::StackItem> _items = stack.pop_items(1);
        const RCalc::StackItem& res = _items[0];
        
        NSMutableArray<NSString*>* inputs = [[NSMutableArray<NSString*> alloc] init];
        
        for (RCalc::Displayable& disp : *res.p_input) {
            switch (disp.get_type()) {
                case RCalc::Displayable::Type::CONST_CHAR: {
                    const char* str = reinterpret_cast<RCalc::ConstCharDisplayable&>(disp).p_char;
                    [inputs addObject:[[NSString alloc] initWithCString:str encoding:NSUTF8StringEncoding]];
                    break;
                }
                case RCalc::Displayable::Type::STRING: {
                    std::string& str = reinterpret_cast<RCalc::StringDisplayable&>(disp).str;
                    [inputs addObject:[[NSString alloc] initWithCString:str.c_str() encoding:NSUTF8StringEncoding]];
                    break;
                }
                case RCalc::Displayable::Type::VALUE: {
                    std::string str = reinterpret_cast<RCalc::ValueDisplayable&>(disp).value.to_string(disp.tags);
                    [inputs addObject:[[NSString alloc] initWithCString:str.c_str() encoding:NSUTF8StringEncoding]];
                    break;
                }
                case RCalc::Displayable::Type::RECURSIVE:
                    UNREACHABLE();
            }
        }
        
        [inputs addObject:@" -> "];
        [processedExample setInputs:inputs];
        
        std::string str = ss.str();
        [processedExample setOutput:[[NSString alloc] initWithCString:str.c_str() encoding:NSUTF8StringEncoding]];
        
        [processedExample setType:(uint8_t)res.result.get_type()];
        
        [processedExample setAccessibiltyValue:OwnString(a11y.str())];
        
        [processedExamples addObject:processedExample];
    }
    
    return processedExamples;
}


@implementation AutoComp

- (void) initSuggestions:(NSString*)str {
    manager.init_suggestions([str UTF8String]);
}

- (NSString*) getNextSuggestion {
    std::optional<std::string> str = manager.get_next_suggestion();
    if (str.has_value()) {
        return [[NSString alloc] initWithCString:str.value().c_str() encoding: NSUTF8StringEncoding];
    }
    return nullptr;
}

- (NSString*) getPreviousSuggestion {
    std::optional<std::string> str = manager.get_previous_suggestion();
    if (str.has_value()) {
        return [[NSString alloc] initWithCString:str.value().c_str() encoding: NSUTF8StringEncoding];
    }
    return nullptr;
}

- (void) cancelSuggestion {
    manager.cancel_suggestion();
}

- (bool) suggestionsActive {
    return manager.suggestions_active();
}

@end

@implementation PreprocessedExample
@end

NSString* OwnString(const std::string& str) {
    return [[NSString alloc] initWithCString: str.c_str() encoding: NSUTF8StringEncoding];
}


const std::vector<RCalc::HelpText::HelpSection> _SwiftRPNHelpSections {
    {
        "Reverse Polish Notation",
R"foo(Most calculators use a style of notation similar to '1 + 2 = 3', known as _infix_ notation. Reverse Polish Notation, or RPN for short, is instead a _postfix_ notation, where operators are placed after their operands (i.e. '1 2 + = 3'). Intuitively, operands are placed into a _stack_, and then operators operate off the top of the stack.

To understand how this works in SwiftRPN, let's examine the `add` operator. Add takes two arguments, referred to as arg0 and arg1, and returns their sum. If you type 1 <enter> 2 <enter>, the stack will have two values. In this example, 1 will become arg0 and 2 will become arg1. Applying the add operator to this stack gives us `1 + 2`.

For a more complicated example,
6 - (4 * sin(pi/2)) would be entered as:
6 <enter> 4 <enter> pi <enter> 2 div <enter> sin <enter> mul <enter> sub <enter>

Notice how we enter our operands first, from the outermost inward, and then apply our operators second, from the innermost outward. People who become proficient at using RPN can enter calculations with great speed.
)foo"
    },
    {
        "Entering Values",
R"foo(SwiftRPN supports a variety of value types and formats, from integers and reals to vectors and matrices.

To enter numbers, you can type them like you normally would. Below are some examples of valid numbers:
123
76.8
0.4
0x80 (Parsed as 128)
0o24 (Parsed as 20)
4e6 (Parsed as 4000000)

To insert negative numbers, or negate a number already on the stack, press the +/- key.

You can additionally swipe up and down on the scratchpad to scroll through the history of values, operators, commands, and units that you have entered.

If the scratchpad is empty, and you press Enter, the top element on the stack will be duplicated. Similarly, if the scratchpad is empty and you press the Delete key, the top element on the stack will be removed.
)foo"
    },
    {
        "Entering Operators",
R"foo(SwiftRPN supports many different operators which are invoked using their name. For example, to calculate the cosine of pi radians, type
pi <enter> cos <enter>

You can also swipe right and left on the scratchpad to autocomplete operators that are available based on the types of values currently in the stack.

Further down on this help page is: a list of all operators, a brief description for each operator, the number of types, and which types, each operator requires, and example(s) of inputs and outputs for each operator.
)foo"
    },
    {
        "Entering Commands",
R"foo(SwiftRPN supports commands at different scopes. Some commands will be available regardless of the renderer, while other commands are renderer specific. You can see a list of all commands and a brief description for each command, separated by scope, further down on this help page.

You can also swipe right and left on the scratchpad to autocomplete commands that are available.

To use a command, enter a backslash ('\') followed by the name of the command.
)foo"
    },
    {
        "Entering Vectors",
R"foo(SwiftRPN supports vectors of 2, 3, and 4 components. To enter vectors, wrap its components in square brackets:
[1, 2]
[6, n4, 9]
[0xfe, 8, n1, 2e9]

You can also create vectors from values on the stack using the vec2, vec3, and vec4 operators, or join scalars and vectors together using the concat operator.

Vectors can be _swizzled_, allowing you to access and rearrange components in a vector. When a vector is at the top of the stack (bottom of the page), enter a period ('.') followed by 1-4 of either xyzw or rgba to select the first, second, third, or fourth component of the vector. Below are some examples of swizzled vectors:
[1, 2].yx -> [2, 1]
[1, 2, 3].xzy -> [1, 3, 2]
[1, 2, 3, 4].rrab -> [1, 1, 4, 3]
[1, 2].rrgg -> [1, 1, 2, 2]
[1, 2, 3, 4].rgb -> [1, 2, 3]
)foo"
    },
    {
        "Entering Matrices",
R"foo(SwiftRPN supports square matrices either 2x2, 3x3, or 4x4 in size. To enter matrices, wrap 2-4 row vectors in curly braces:
{[1, 2], [3, 4]}
{[1, 0, 0], [0, 1, 0], [0, 0, 1]}
{[4, 8, n3, 5], [n2, n2, 4, 0], [0x12, 9, 4, 3en4], [0, 1, 32, 9]}

You can also create matrices from row vectors on the stack using the mat2, mat3, and mat4 operators.
)foo"
    },
    {
        "Unit Conversions",
R"foo(SwiftRPN supports converting between units in the same family. To enter a unit, enter an underscore ('_') followed by its abbreviation. For example:
_ft (Feet)
_lbs (Pounds)
_c (Celsius)
_polar (Polar r and theta)
_oklch (OKLCh color space)

You can also swipe right and left on the scratchpad to autocomplete units that are available based on the types of values currently in the stack.

You can see a list of all unit families, the base type used by each family, and the unit name and usage for each unit that belongs to the family further down on this help page.

To convert a value, push it onto the stack, followed by the unit you want to convert from, then the unit you want to convert to, then use the convert operator. For example:
78 <enter> _f <enter> _c <enter> convert <enter> = 25.5556
[1, 1.5708] <enter> _polar <enter> _cartxy <enter> convert <enter> = [0, 1]
[200, 164, 237] <enter> _rgb <enter> _hsl <enter> convert <enter> = [269.589, 66.9725, 78.6275]
)foo"
    }
};


const std::vector<RCalc::HelpText::HelpSection>& SwiftRPNHelpSections() {
    return _SwiftRPNHelpSections;
}


const char* LicenseInfo = R"foo(All source code created for SwiftRPN in this repo is available under the following license:

MIT License

Copyright (c) Patrick Gelvin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


====


Certain files used in the SCons build system are either modified from, or take
direct inspiration from, the Godot Engine project. These files can be found at
https://github.com/godotengine/godot and are licensed under the following license:

Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md).
Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


====


Portions of the core/error.{h,cpp} files are copied or directly inspired by
the Result project found at https://github.com/oktal/result. These files
are licensed under the following license:

                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   APPENDIX: How to apply the Apache License to your work.

      To apply the Apache License to your work, attach the following
      boilerplate notice, with the fields enclosed by brackets "{}"
      replaced with your own identifying information. (Don't include
      the brackets!)  The text should be enclosed in the appropriate
      comment syntax for the file format. We also recommend that a
      file or class name and description of purpose be included on the
      same "printed page" as the copyright notice for easier
      identification within third-party archives.

   Copyright {2016} {Mathieu Stefani}

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.


====


The file at modules/bigint/bigint.h is created by Roshan Gupta,
and is available under the following license:

MIT License

Copyright (c) 2020 Roshan Gupta

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


====


The files in modules/glm are created by G-Truc and are available
under the following license:

The MIT License
--------------------------------------------------------------------------------
Copyright (c) 2005 - G-Truc Creation

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
)foo";


NSString* GetLicenseInfo() {
    return [[NSString alloc] initWithCString:LicenseInfo encoding: NSUTF8StringEncoding];
}
