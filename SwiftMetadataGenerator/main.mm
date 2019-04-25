//
//  main.cpp
//  SwiftMetadataGenerator
//
//  Created by Teodor Dermendzhiev on 4/24/19.
//  Copyright © 2019 Teodor Dermendzhiev. All rights reserved.
//

#include <iostream>
#include "sourcekitd.h"

bool apply(sourcekitd_uid_t key, sourcekitd_variant_t value) {
    return true;
}

int main(int argc, const char * argv[]) {
    sourcekitd_initialize();
    const char* filePath = "/Users/dermendz/dev/SwiftMetadataGenerator/SwiftTest.swift";
    sourcekitd_object_t request = sourcekitd_request_dictionary_create(nullptr, nullptr, 0);
    sourcekitd_uid_t v = sourcekitd_uid_get_from_cstr("source.request.editor.open");
    sourcekitd_uid_t k = sourcekitd_uid_get_from_cstr("key.request");
    sourcekitd_request_dictionary_set_uid(request, k, v);
    sourcekitd_request_dictionary_set_string(request, sourcekitd_uid_get_from_cstr("key.name"), filePath);
    sourcekitd_request_dictionary_set_string(request, sourcekitd_uid_get_from_cstr("key.sourcefile"), filePath);
    
    const sourcekitd_object_t arg1 = sourcekitd_request_string_create("/Users/dermendz/dev/SwiftMetadataGenerator/SwiftTest.swift");
    sourcekitd_object_t args = sourcekitd_request_array_create(&arg1, 1);
    sourcekitd_request_dictionary_set_value(request, sourcekitd_uid_get_from_cstr("key.compilerargs"), args);
    
    sourcekitd_response_t reply = sourcekitd_send_request_sync(request);

//    _xpc_object_validate((xpc_object_t)CFBridgingRelease(reply));
    bool err = sourcekitd_response_is_error(reply);
    if (err) {
        sourcekitd_error_t errType = sourcekitd_response_error_get_kind(reply);
        
        
        const char * desc = sourcekitd_response_error_get_description(reply);
        std::cout << desc << "\n";
    } else {
        sourcekitd_variant_t value = sourcekitd_response_get_value(reply);
        sourcekitd_variant_dictionary_applier_t applier = ^(sourcekitd_uid_t key, sourcekitd_variant_t value) {
            const char* keyName = sourcekitd_uid_get_string_ptr(key);
            sourcekitd_variant_type_t type = sourcekitd_variant_get_type(value);
            return true;
        };
        sourcekitd_variant_dictionary_apply(value, applier);
        
        
        char* res = sourcekitd_response_description_copy(reply);
        std::cout << res << "\n";
    }
    
    
    sourcekitd_request_description_dump(request);
    
    return 0;
}
