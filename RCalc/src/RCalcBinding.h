//
//  RCalcBinding.h
//  SwiftRPN
//
//  Created by Patrick Gelvin on 10/31/23.
//

#ifndef RCalcBinding_h
#define RCalcBinding_h

#include <Foundation/Foundation.h>

#include "app/application.h"
#include "app/renderers/renderer.h"
#include "app/commands/commands.h"
#include "app/help_text.h"
#include "app/autocomplete.h"

#include <string>
#include <vector>


RCalc::Application* UnwrapApplicationResult(RCalc::Result<RCalc::Application*> res);

void RCalcSubmitText(NSString* text);

RCalc::Type RCalcTypeFromUInt8(uint8_t type);

NSString* GetVersionString();
NSString* GetLicenseInfo();

void register_SwiftRPN_commands();
NSArray<NSString*>* get_command_aliases(const std::vector<const char*>& aliases);
NSString* get_type_name(RCalc::Type type);

const std::vector<RCalc::HelpText::HelpSection>& SwiftRPNHelpSections();

@interface AutoComp : NSObject {
    RCalc::AutocompleteManager manager;
}

- (void) initSuggestions:(NSString*)str;
- (NSString*) getNextSuggestion;
- (NSString*) getPreviousSuggestion;
- (void) cancelSuggestion;

- (bool) suggestionsActive;

@end

@interface PreprocessedExample : NSObject {}

@property NSArray<NSString*>* inputs;
@property NSString* output;
@property uint8_t type;
@property NSString* accessibiltyValue;

@end

NSArray<PreprocessedExample*>* preprocess_operator_examples(const RCalc::Operator& op);

std::string get_accessibility_value(RCalc::Value value);
NSString* OwnString(const std::string& str);

#endif /* RCalcBinding_h */
