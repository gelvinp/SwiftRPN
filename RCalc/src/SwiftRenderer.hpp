//
//  SwiftRenderer.hpp
//  SwiftRPN
//
//  Created by Patrick Gelvin on 10/31/23.
//

#ifndef SwiftRenderer_hpp
#define SwiftRenderer_hpp

#include <stdio.h>
#include "app/renderers/renderer.h"
#include "SwiftBackend.hpp"

namespace RCalc {

class SwiftRenderer : public Renderer {
public:
    SwiftRenderer(SubmitTextCallback cb_submit_text);

    virtual Result<> init() override { return Ok(); }
    
    virtual void render_loop() override {}
    virtual void cleanup() override {}

    virtual void display_info(std::string_view str) override;
    virtual void display_error(std::string_view str) override;

    virtual bool try_renderer_command(std::string_view str) override;

    virtual void add_stack_item(const StackItem& item) override;
    virtual void remove_stack_item() override;
    virtual void replace_stack_items(const CowVec<StackItem>& items) override;
};


}


#endif /* SwiftRenderer_hpp */
