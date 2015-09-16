@[IncludeFlags("-I/usr/local/Cellar/llvm/3.6.2/include  -fPIC -fvisibility-inlines-hidden -Wall -W -Wno-unused-parameter -Wwrite-strings -Wcast-qual -Wmissing-field-initializers -pedantic -Wno-long-long -Wcovered-switch-default -Wnon-virtual-dtor -std=c++11   -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS")]
@[Include("llvm-c/Core.h")]
@[Include("llvm-c/ExecutionEngine.h")]
@[Include("llvm-c/Transforms/PassManagerBuilder.h")]
@[Include("llvm-c/BitWriter.h")]
@[Include("llvm-c/Analysis.h")]
@[Include("llvm-c/Initialization.h")]
@[Link("stdc++")]
@[Link(ldflags: "`(llvm-config-3.6 --libs --system-libs --ldflags 2> /dev/null) || (llvm-config-3.5 --libs --system-libs --ldflags 2> /dev/null) || (llvm-config --libs --system-libs --ldflags 2>/dev/null)`")]
lib LibLLVM
  fun add_attribute = LLVMAddAttribute
  fun add_instr_attribute = LLVMAddInstrAttribute
  fun add_case = LLVMAddCase
  fun add_clause = LLVMAddClause
  fun add_function = LLVMAddFunction
  fun add_function_attr = LLVMAddFunctionAttr
  fun get_function_attr = LLVMGetFunctionAttr
  fun add_global = LLVMAddGlobal
  fun add_incoming = LLVMAddIncoming
  fun add_named_metadata_operand = LLVMAddNamedMetadataOperand
  fun add_target_dependent_function_attr = LLVMAddTargetDependentFunctionAttr
  fun append_basic_block = LLVMAppendBasicBlock
  fun array_type = LLVMArrayType
  fun vector_type = LLVMVectorType
  fun build_add = LLVMBuildAdd
  fun build_alloca = LLVMBuildAlloca
  fun build_and = LLVMBuildAnd
  fun build_array_malloc = LLVMBuildArrayMalloc
  fun build_ashr = LLVMBuildAShr
  fun build_bit_cast = LLVMBuildBitCast
  fun build_br = LLVMBuildBr
  fun build_call = LLVMBuildCall
  fun build_cond = LLVMBuildCondBr
  fun build_exact_sdiv = LLVMBuildExactSDiv
  fun build_extract_value = LLVMBuildExtractValue
  fun build_fadd = LLVMBuildFAdd
  fun build_fcmp = LLVMBuildFCmp
  fun build_fdiv = LLVMBuildFDiv
  fun build_fmul = LLVMBuildFMul
  fun build_fp2si = LLVMBuildFPToSI
  fun build_fp2ui = LLVMBuildFPToUI
  fun build_fpext = LLVMBuildFPExt
  fun build_fptrunc = LLVMBuildFPTrunc
  fun build_fsub = LLVMBuildFSub
  fun build_gep = LLVMBuildGEP
  fun build_inbounds_gep = LLVMBuildInBoundsGEP
  fun build_global_string_ptr = LLVMBuildGlobalStringPtr
  fun build_icmp = LLVMBuildICmp
  fun build_int2ptr = LLVMBuildIntToPtr
  fun build_invoke = LLVMBuildInvoke
  fun build_landing_pad = LLVMBuildLandingPad
  fun build_load = LLVMBuildLoad
  fun build_lshr = LLVMBuildLShr
  fun build_malloc = LLVMBuildMalloc
  fun build_mul = LLVMBuildMul
  fun build_not = LLVMBuildNot
  fun build_or = LLVMBuildOr
  fun build_phi = LLVMBuildPhi
  fun build_ptr2int = LLVMBuildPtrToInt
  fun build_ret = LLVMBuildRet
  fun build_ret_void = LLVMBuildRetVoid
  fun build_sdiv = LLVMBuildSDiv
  fun build_select = LLVMBuildSelect
  fun build_sext = LLVMBuildSExt
  fun build_shl = LLVMBuildShl
  fun build_si2fp = LLVMBuildSIToFP
  fun build_si2fp = LLVMBuildSIToFP
  fun build_srem = LLVMBuildSRem
  fun build_store = LLVMBuildStore
  fun build_sub = LLVMBuildSub
  fun build_switch = LLVMBuildSwitch
  fun build_trunc = LLVMBuildTrunc
  fun build_udiv = LLVMBuildUDiv
  fun build_ui2fp = LLVMBuildSIToFP
  fun build_ui2fp = LLVMBuildUIToFP
  fun build_unreachable = LLVMBuildUnreachable
  fun build_urem = LLVMBuildURem
  fun build_xor = LLVMBuildXor
  fun build_zext = LLVMBuildZExt
  fun const_array = LLVMConstArray
  fun const_int = LLVMConstInt
  fun const_null = LLVMConstNull
  fun const_pointer_null = LLVMConstPointerNull
  fun const_real = LLVMConstReal
  fun const_real_of_string = LLVMConstRealOfString
  fun const_string = LLVMConstString
  fun const_struct = LLVMConstStruct
  fun count_param_types = LLVMCountParamTypes
  fun create_builder = LLVMCreateBuilder : BuilderRef
  fun create_generic_value_of_int = LLVMCreateGenericValueOfInt
  fun create_generic_value_of_pointer = LLVMCreateGenericValueOfPointer
  fun create_jit_compiler_for_module = LLVMCreateJITCompilerForModule
  fun create_mc_jit_compiler_for_module = LLVMCreateMCJITCompilerForModule
  fun create_target_machine = LLVMCreateTargetMachine
  fun delete_basic_block = LLVMDeleteBasicBlock
  fun dispose_message = LLVMDisposeMessage
  fun double_type = LLVMDoubleType : TypeRef
  fun dump_module = LLVMDumpModule
  fun dump_value = LLVMDumpValue
  fun target_machine_emit_to_file = LLVMTargetMachineEmitToFile
  fun float_type = LLVMFloatType : TypeRef
  fun function_type = LLVMFunctionType
  fun generic_value_to_float = LLVMGenericValueToFloat
  fun generic_value_to_int = LLVMGenericValueToInt
  fun generic_value_to_pointer = LLVMGenericValueToPointer
  fun get_attribute = LLVMGetAttribute
  fun get_current_debug_location = LLVMGetCurrentDebugLocation
  fun get_element_type = LLVMGetElementType
  fun get_first_instruction = LLVMGetFirstInstruction
  fun get_first_target = LLVMGetFirstTarget : TargetRef
  fun get_global_context = LLVMGetGlobalContext : ContextRef
  fun get_insert_block = LLVMGetInsertBlock
  fun get_named_function = LLVMGetNamedFunction
  fun get_named_global = LLVMGetNamedGlobal
  fun get_param = LLVMGetParam
  fun get_param_types = LLVMGetParamTypes
  fun get_params = LLVMGetParams
  fun get_pointer_to_global = LLVMGetPointerToGlobal
  fun get_return_type = LLVMGetReturnType
  fun get_target_name = LLVMGetTargetName
  fun get_target_description = LLVMGetTargetDescription
  fun get_target_machine_data = LLVMGetTargetMachineData
  fun get_target_machine_triple = LLVMGetTargetMachineTriple
  fun get_target_from_triple = LLVMGetTargetFromTriple
  fun get_type_kind = LLVMGetTypeKind
  fun get_undef = LLVMGetUndef
  fun get_value_name = LLVMGetValueName
  fun initialize_x86_asm_printer = LLVMInitializeX86AsmPrinter
  fun initialize_x86_asm_parser = LLVMInitializeX86AsmParser
  fun initialize_x86_target = LLVMInitializeX86Target
  fun initialize_x86_target_info = LLVMInitializeX86TargetInfo
  fun initialize_x86_target_mc = LLVMInitializeX86TargetMC
  fun initialize_native_target = LLVMInitializeNativeTarget
  fun int1_type = LLVMInt1Type : TypeRef
  fun int8_type = LLVMInt8Type : TypeRef
  fun int16_type = LLVMInt16Type : TypeRef
  fun int32_type = LLVMInt32Type : TypeRef
  fun int64_type = LLVMInt64Type : TypeRef
  fun int_type = LLVMIntType
  fun is_constant = LLVMIsConstant
  fun is_function_var_arg = LLVMIsFunctionVarArg
  fun md_node = LLVMMDNode
  fun md_string = LLVMMDString
  fun module_create_with_name = LLVMModuleCreateWithName
  fun pass_manager_builder_create = LLVMPassManagerBuilderCreate : PassManagerBuilderRef
  fun pass_manager_builder_set_opt_level = LLVMPassManagerBuilderSetOptLevel
  fun pass_manager_builder_set_size_level = LLVMPassManagerBuilderSetSizeLevel
  fun pass_manager_builder_set_disable_unroll_loops = LLVMPassManagerBuilderSetDisableUnrollLoops
  fun pass_manager_builder_set_disable_simplify_lib_calls = LLVMPassManagerBuilderSetDisableSimplifyLibCalls
  fun pass_manager_builder_use_inliner_with_threshold = LLVMPassManagerBuilderUseInlinerWithThreshold
  fun pass_manager_builder_populate_function_pass_manager = LLVMPassManagerBuilderPopulateFunctionPassManager
  fun pass_manager_builder_populate_module_pass_manager = LLVMPassManagerBuilderPopulateModulePassManager
  fun pass_manager_create = LLVMCreatePassManager : PassManagerRef
  fun create_function_pass_manager_for_module = LLVMCreateFunctionPassManagerForModule
  fun pointer_type = LLVMPointerType
  fun position_builder_at_end = LLVMPositionBuilderAtEnd
  fun print_module_to_file = LLVMPrintModuleToFile
  fun run_function = LLVMRunFunction
  fun run_pass_manager = LLVMRunPassManager
  fun initialize_function_pass_manager = LLVMInitializeFunctionPassManager
  fun run_function_pass_manager = LLVMRunFunctionPassManager
  fun finalize_function_pass_manager = LLVMFinalizeFunctionPassManager
  fun set_cleanup = LLVMSetCleanup
  fun set_data_layout = LLVMSetDataLayout
  fun set_global_constant = LLVMSetGlobalConstant
  fun is_global_constant = LLVMIsGlobalConstant
  fun set_initializer = LLVMSetInitializer
  fun get_initializer = LLVMGetInitializer
  fun set_linkage = LLVMSetLinkage
  fun get_linkage = LLVMGetLinkage
  fun set_metadata = LLVMSetMetadata
  fun set_target = LLVMSetTarget
  fun set_thread_local = LLVMSetThreadLocal
  fun is_thread_local = LLVMIsThreadLocal
  fun set_value_name = LLVMSetValueName
  fun size_of = LLVMSizeOf
  fun size_of_type_in_bits = LLVMSizeOfTypeInBits
  fun struct_create_named = LLVMStructCreateNamed
  fun struct_set_body = LLVMStructSetBody
  fun struct_type = LLVMStructType
  fun type_of = LLVMTypeOf
  fun void_type = LLVMVoidType : TypeRef
  fun write_bitcode_to_file = LLVMWriteBitcodeToFile
  fun verify_module = LLVMVerifyModule
  fun link_in_mc_jit = LLVMLinkInMCJIT
  fun start_multithreaded = LLVMStartMultithreaded : Int32
  fun stop_multithreaded = LLVMStopMultithreaded
  fun is_multithreaded = LLVMIsMultithreaded : Int32
  fun get_md_kind_id = LLVMGetMDKindID
  fun get_first_function = LLVMGetFirstFunction
  fun get_next_function = LLVMGetNextFunction
  fun get_global_pass_registry = LLVMGetGlobalPassRegistry : PassRegistryRef
  fun initialize_core = LLVMInitializeCore
  fun initialize_transform_utils = LLVMInitializeTransformUtils
  fun initialize_scalar_opts = LLVMInitializeScalarOpts
  fun initialize_obj_c_arc_opts = LLVMInitializeObjCARCOpts
  fun initialize_vectorization = LLVMInitializeVectorization
  fun initialize_inst_combine = LLVMInitializeInstCombine
  fun initialize_ipo = LLVMInitializeIPO
  fun initialize_instrumentation = LLVMInitializeInstrumentation
  fun initialize_analysis = LLVMInitializeAnalysis
  fun initialize_ipa = LLVMInitializeIPA
  fun initialize_code_gen = LLVMInitializeCodeGen
  fun initialize_target = LLVMInitializeTarget
  fun add_target_data = LLVMAddTargetData
  fun get_next_target = LLVMGetNextTarget
  fun get_default_target_triple = LLVMGetDefaultTargetTriple : UInt8*
  fun print_module_to_string = LLVMPrintModuleToString
  fun print_type_to_string = LLVMPrintTypeToString
  fun print_value_to_string = LLVMPrintValueToString
  fun get_function_call_convention = LLVMGetFunctionCallConv
  fun set_function_call_convention = LLVMSetFunctionCallConv
  fun set_instruction_call_convention = LLVMSetInstructionCallConv
  fun get_instruction_call_convention = LLVMGetInstructionCallConv
  fun get_int_type_width = LLVMGetIntTypeWidth
  fun is_packed_struct = LLVMIsPackedStruct
  fun get_struct_element_types = LLVMGetStructElementTypes
  fun count_struct_element_types = LLVMCountStructElementTypes
  fun get_element_type = LLVMGetElementType
  fun get_array_length = LLVMGetArrayLength
  fun abi_size_of_type = LLVMABISizeOfType
  fun abi_alignment_of_type = LLVMABIAlignmentOfType
  fun get_target_machine_target = LLVMGetTargetMachineTarget
  fun const_inline_asm = LLVMConstInlineAsm
end