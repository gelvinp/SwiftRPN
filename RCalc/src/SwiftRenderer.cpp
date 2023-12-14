//
//  SwiftBackend.cpp
//  SwiftRPN
//
//  Created by Patrick Gelvin on 10/31/23.
//

#include "SwiftRenderer.hpp"


namespace RCalc {

Result<Renderer*> Renderer::create(const std::string_view& name, SubmitTextCallback cb_submit_text) {
    Renderer* p_renderer = reinterpret_cast<Renderer*>(new SwiftRenderer(cb_submit_text));

    Result<> res = p_renderer->init();
    if (!res) { return res.unwrap_err(); }

    return Ok(p_renderer);
}

SwiftRenderer::SwiftRenderer(SubmitTextCallback cb_submit_text) {
    SwiftBackend::singleton.cb_submit_text = cb_submit_text;
}


void SwiftRenderer::display_info(std::string_view str) {
    SwiftBackend::singleton.Swift_DisplayInfo(str);
}

void SwiftRenderer::display_error(std::string_view str) {
    SwiftBackend::singleton.Swift_DisplayError(str);
}


bool SwiftRenderer::try_renderer_command(std::string_view str) {
    return SwiftBackend::singleton.Swift_TryRenderCommand(str);
}


void SwiftRenderer::add_stack_item(const StackItem& item) {
    SwiftBackend::singleton.Swift_AddStackItem(item);
}

void SwiftRenderer::remove_stack_item() {
    SwiftBackend::singleton.Swift_RemoveStackItem();
}

void SwiftRenderer::replace_stack_items(const CowVec<StackItem>& items) {
    SwiftBackend::singleton.Swift_ReplaceStackItems(items);
}

}
