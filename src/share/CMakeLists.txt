set(_copy_files_target Binop_CopySharedFiles)

add_custom_target(${_copy_files_target} ALL)

binop_add_attached_files(${_copy_files_target}
    SRC data DEST ${BINOP_BUILD_DATA_DIR}
    SRC doc DEST ${BINOP_BUILD_DOC_DIR}
)