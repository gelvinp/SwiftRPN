//
//  SwiftBackend.cpp
//  SwiftRPN
//
//  Created by Patrick Gelvin on 10/31/23.
//

#include "SwiftBackend.hpp"
#include "SwiftRenderer.hpp"

#include <SwiftRPN-Swift.h>

#include "core/format.h"

std::string get_accessibility_value(RCalc::Value value) {
    switch (value.get_type()) {
        case RCalc::Type::TYPE_INT:
        case RCalc::Type::TYPE_BIGINT:
        case RCalc::Type::TYPE_REAL:
        case RCalc::Type::TYPE_UNIT:
            return value.to_string();
        case RCalc::Type::TYPE_VEC2: {
            RCalc::Vec2 val = value;
            return RCalc::fmt("Vector with components %.15g, and %.15g", val.x, val.y);
        }
        case RCalc::Type::TYPE_VEC3: {
            RCalc::Vec3 val = value;
            return RCalc::fmt("Vector with components %.15g, %.15g, and %.15g", val.x, val.y, val.z);
        }
        case RCalc::Type::TYPE_VEC4: {
            RCalc::Vec4 val = value;
            return RCalc::fmt("Vector with components %.15g, %.15g, %.15g, and %.15g", val.x, val.y, val.z, val.w);
        }
        case RCalc::Type::TYPE_MAT2: {
            RCalc::Mat2 val = value;
            return RCalc::fmt("Matrix with row 1 components %.15g, and %.15g, and row 2 components %.15g, and %.15g", val[0].x, val[1].x, val[0].y, val[1].y);
        }
        case RCalc::Type::TYPE_MAT3: {
            RCalc::Mat3 val = value;
            return RCalc::fmt("Matrix with row 1 components %.15g, %.15g, and %.15g, row 2 components %.15g, %.15g, and %.15g, and row 3 components %.15g, %.15g, and %.15g", val[0].x, val[1].x, val[2].x, val[0].y, val[1].y, val[2].y, val[0].z, val[1].z, val[2].z);
        }
        case RCalc::Type::TYPE_MAT4: {
            RCalc::Mat4 val = value;
            return RCalc::fmt("Matrix with row 1 components %.15g, %.15g, %.15g, and %.15g, row 2 components %.15g, %.15g, %.15g, and %.15g, row 3 components %.15g, %.15g, %.15g, and %.15g, and row 4 components %.15g, %.15g, %.15g, and %.15g", val[0].x, val[1].x, val[2].x, val[3].x, val[0].y, val[1].y, val[2].y, val[3].y, val[0].z, val[1].z, val[2].z, val[3].z, val[0].w, val[1].w, val[2].w, val[3].w);
        }
        default: {
            UNREACHABLE();
        }
    }
}



namespace RCalc {

SwiftBackend SwiftBackend::singleton;


void SwiftBackend::Swift_DisplayInfo(std::string_view message) {
    SwiftRPN::RCalcBridge::display_info(swift::String(message.data()));
}

void SwiftBackend::Swift_DisplayError(std::string_view error) {
    SwiftRPN::RCalcBridge::display_error(swift::String(error.data()));
}

bool SwiftBackend::Swift_TryRenderCommand(std::string_view command) {
    return SwiftRPN::RCalcBridge::try_render_command(swift::String(command.data()));
}

void SwiftBackend::Swift_AddStackItem(const StackItem& item) {
    SwiftRPN::RCalcBridge::start_stack_item();
    
    for (Displayable& disp : *item.p_input) {
        std::string str;

        switch (disp.get_type()) {
            case Displayable::Type::CONST_CHAR: {
                str = reinterpret_cast<ConstCharDisplayable&>(disp).p_char;
                break;
            }
            case Displayable::Type::STRING: {
                str = reinterpret_cast<StringDisplayable&>(disp).str;
                break;
            }
            case Displayable::Type::VALUE: {
                str = reinterpret_cast<ValueDisplayable&>(disp).value.to_string(disp.tags);
                break;
            }
            case Displayable::Type::RECURSIVE:
                UNREACHABLE(); // Handled by the iterator
        }
        
        SwiftRPN::RCalcBridge::append_stack_item(swift::String(str));
    }
    
    SwiftRPN::RCalcBridge::finish_stack_item(swift::String(item.result.to_string(item.p_input->tags)), (uint8_t)item.result.get_type(), get_accessibility_value(item.result));
}

void SwiftBackend::Swift_RemoveStackItem() {
    SwiftRPN::RCalcBridge::remove_stack_item();
}

void SwiftBackend::Swift_ReplaceStackItems(const CowVec<RCalc::StackItem>& items) {
    SwiftRPN::RCalcBridge::clear_stack();
    
    for (const RCalc::StackItem& item : items) {
        Swift_AddStackItem(item);
    }
}

}
