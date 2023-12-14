//
//  SwiftBackend.hpp
//  SwiftRPN
//
//  Created by Patrick Gelvin on 10/31/23.
//

#ifndef SwiftBackend_hpp
#define SwiftBackend_hpp

#include <stdio.h>

#include "app/stack.h"
#include "app/renderers/renderer.h"

namespace RCalc {


class SwiftBackend {
public:
    void copy_to_clipboard(std::string_view string) {}
    
    void Swift_DisplayInfo(std::string_view message);
    void Swift_DisplayError(std::string_view error);
    
    bool Swift_TryRenderCommand(std::string_view command);
    
    void Swift_AddStackItem(const RCalc::StackItem& item);
    void Swift_RemoveStackItem();
    void Swift_ReplaceStackItems(const CowVec<RCalc::StackItem>& items);
    
    static SwiftBackend singleton;
    
    Renderer::SubmitTextCallback cb_submit_text;
};


}

#endif /* SwiftBackend_hpp */
