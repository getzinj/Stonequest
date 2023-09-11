[Environment('smgrtl')]
MODULE smgrtl;

{
PROGRAM DESCRIPTION:

        This module declares all SMG$ routines externally

AUTHORS:

        Peter Laman

CREATION DATE:  16-Sep-1986


CHANGE LOG

   Date       |   Name       |  Description
--------------+--------------+----------------------------------------------------
  9/16/88      Jeffrey Getzin Improvements on old file, plus additional routines
%[Change_entry]%
}

[HIDDEN]
TYPE
  $bool = [BIT] BOOLEAN;
  $ubyte = [BYTE, UNSAFE] CHAR;
  $byte = [BYTE, UNSAFE] -127 .. 127;
  $uword = [WORD, UNSAFE] 0 .. 65535;
  $word = [WORD, UNSAFE] -32768 .. 32767;
  $unspecified = [LONG, UNSAFE] UNSIGNED;
  $quad = [UNSAFE] Record
                     lsl,msl:  [UNSAFE] INTEGER;
                   End;
  $uquad = [UNSAFE] Record
                      lsl,msl:  [UNSAFE] INTEGER;
                    End;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$ADD_KEY_DEF
  (          key_table_id: UNSIGNED;
             key_name: character string;
             if_state: character string;
             attributes: UNSIGNED;
             equivalence_string: character string;
             state_string: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$BEGIN_DISPLAY_UPDATE
  (          display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$BEGIN_PASTEBOARD_UPDATE
  (          pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CANCEL_INPUT
  (          keyboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CHANGE_PBD_CHARACTERISTICS
  (          pasteboard_id: UNSIGNED;
             desired_width: INTEGER;
             VAR width: INTEGER;
             desired_height: INTEGER;
             VAR height: INTEGER;
             desired_background_color: UNSIGNED;
             VAR background_color: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CHANGE_RENDITION
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             number_of_rows: INTEGER;
             number_of_columns: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CHANGE_VIEWPORT
  (          display_id: UNSIGNED;
             viewport_row_start: INTEGER;
             viewport_column_start: INTEGER;
             viewport_number_rows: INTEGER;
             viewport_number_columns: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CHANGE_VIRTUAL_DISPLAY
  (          display_id: UNSIGNED;
             number_of_rows: INTEGER;
             number_of_columns: INTEGER;
             display_attributes: UNSIGNED;
             video_attributes: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CHECK_FOR_OCCLUSION
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             VAR occlusion_state: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CONTROL_MODE
  (          pasteboard_id: UNSIGNED;
             new_mode: UNSIGNED;
             VAR old_mode: UNSIGNED;
             buffer_size: word (unsigned);
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$COPY_VIRTUAL_DISPLAY
  (          current_display_id: UNSIGNED;
             VAR new_display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CREATE_KEY_TABLE
  (          VAR key_table_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CREATE_MENU
  (%Ref          display_id: UNSIGNED;
   %Desc          choices: character string;
   %Ref          menu_type: UNSIGNED;
   %Ref          flags: UNSIGNED;
   %Ref          row: INTEGER;
   %Ref          rendition_set: UNSIGNED;
   %Ref          rendition_complement: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CREATE_PASTEBOARD
  (          VAR pasteboard_id: UNSIGNED;
             output_device: character string;
             VAR number_of_pasteboard_rows: INTEGER;
             VAR number_of_pasteboard_columns: INTEGER;
             flags: UNSIGNED;
             VAR type_of_terminal: UNSIGNED;
             VAR device_name: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CREATE_SUBPROCESS
  (          display_id: UNSIGNED;
             <call without stack unwinding> AST_routine: procedure value;
             AST_argument: UNSIGNED;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CREATE_VIEWPORT
  (          display_id: UNSIGNED;
             viewport_row_start: INTEGER;
             viewport_column_start: INTEGER;
             viewport_number_rows: INTEGER;
             viewport_number_columns: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CREATE_VIRTUAL_DISPLAY
  (          number_of_rows: INTEGER;
             number_of_columns: INTEGER;
             VAR display_id: UNSIGNED;
             display_attributes: UNSIGNED;
             video_attributes: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CREATE_VIRTUAL_KEYBOARD
  (          VAR keyboard_id: UNSIGNED;
             input_device: character string;
             default_filespec: character string;
             VAR resultant_filespec: character string;
             recall_size: byte (unsigned);
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CURSOR_COLUMN
  (          display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$CURSOR_ROW
  (          display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DEFINE_KEY
  (          key_table_id: UNSIGNED;
             command_string: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DELETE_CHARS
  (          display_id: UNSIGNED;
             number_of_characters: INTEGER;
             start_row: INTEGER;
             start_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DELETE_KEY_DEF
  (          key_table_id: UNSIGNED;
             key_name: character string;
             if_state: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DELETE_LINE
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             number_of_rows: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DELETE_MENU
  (          display_id: UNSIGNED;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DELETE_PASTEBOARD
  (          pasteboard_id: UNSIGNED;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DELETE_SUBPROCESS
  (          display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DELETE_VIEWPORT
  (          display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DELETE_VIRTUAL_DISPLAY
  (          display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DELETE_VIRTUAL_KEYBOARD
  (          keyboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DEL_TERM_TABLE
  (
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DISABLE_BROADCAST_TRAPPING
  (          pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DISABLE_UNSOLICITED_INPUT
  (          pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DRAW_CHAR
  (          display_id: UNSIGNED;
             flags: UNSIGNED;
             row: INTEGER;
             column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DRAW_LINE
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             end_row: INTEGER;
             end_column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$DRAW_RECTANGLE
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             end_row: INTEGER;
             end_column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$ENABLE_UNSOLICITED_INPUT
  (          pasteboard_id: UNSIGNED;
             AST_routine: procedure value;
             AST_argument: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$END_DISPLAY_UPDATE
  (          display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$END_PASTEBOARD_UPDATE
  (          pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$ERASE_CHARS
  (          display_id: UNSIGNED;
             number_of_characters: INTEGER;
             start_row: INTEGER;
             start_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$ERASE_COLUMN
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             column_number: INTEGER;
             end_row: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$ERASE_DISPLAY
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             end_row: INTEGER;
             end_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$ERASE_LINE
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$ERASE_PASTEBOARD
  (          pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$EXECUTE_COMMAND
  (          display_id: UNSIGNED;
             command_desc: character string;
             flags: UNSIGNED;
             VAR ret_status: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$FIND_CURSOR_DISPLAY
  (          pasteboard_id: UNSIGNED;
             VAR display_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$FLUSH_BUFFER
  (          pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$FLUSH_DISPLAY_UPDATE
  (          display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_BROADCAST_MESSAGE
  (          pasteboard_id: UNSIGNED;
             VAR message: character string;
             VAR message_length: word (unsigned);
             VAR message_type: word (unsigned);
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_CHAR_AT_PHYSICAL_CURSOR
  (          pasteboard_id: UNSIGNED;
             VAR character_code: byte (unsigned);
             VAR rendition: byte (unsigned);
             VAR user_rendition: byte (unsigned);
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_DISPLAY_ATTR
  (          display_id: UNSIGNED;
             VAR height: INTEGER;
             VAR width: INTEGER;
             VAR display_attributes: UNSIGNED;
             VAR video_attributes: UNSIGNED;
             VAR character_set: UNSIGNED;
             VAR flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_KEYBOARD_ATTRIBUTES
  (          keyboard_id: UNSIGNED;
             VAR keyboard_info_table: unspecified;
             keyboard_info_table_size: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_KEY_DEF
  (          key_table_id: UNSIGNED;
             key_name: character string;
             if_state: character string;
             VAR attributes: UNSIGNED;
             VAR equivalence_string: character string;
             VAR state_string: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_NUMERIC_DATA
  (          termtable_address: UNSIGNED;
             request_code: UNSIGNED;
             VAR buffer_address: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_PASTEBOARD_ATTRIBUTES
  (          pasteboard_id: UNSIGNED;
             VAR pasteboard_info_table: unspecified;
             pasteboard_info_table_size: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_PASTING_INFO
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             VAR flags: UNSIGNED;
             VAR pasteboard_row: INTEGER;
             VAR pasteboard_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_TERM_DATA
  (          termtable_address: UNSIGNED;
             request_code: INTEGER;
             maximum_buffer_length: INTEGER;
             VAR return_length: INTEGER;
             <by reference, array reference> capability_data: unspecified;
             input_argument_vector: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$GET_VIEWPORT_CHAR
  (          display_id: UNSIGNED;
             VAR viewport_row_start: INTEGER;
             VAR viewport_column_start: INTEGER;
             VAR viewport_number_rows: INTEGER;
             VAR viewport_number_columns: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$HOME_CURSOR
  (          display_id: UNSIGNED;
             position_code: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$INIT_TERM_TABLE
  (          terminal_name: character string;
             VAR termtable_address: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$INIT_TERM_TABLE_BY_TYPE
  (          terminal_type: $byte;
             VAR termtable_address: UNSIGNED;
             VAR terminal_name: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$INSERT_CHARS
  (          display_id: UNSIGNED;
             character_string: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$INSERT_LINE
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             character_string: character string;
             direction: UNSIGNED;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             flags: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$INVALIDATE_DISPLAY
  (          display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$KEYCODE_TO_NAME
  (          key_code: word (unsigned);
             VAR key_name: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$LABEL_BORDER
  (          display_id: UNSIGNED;
             text: character string;
             position_code: UNSIGNED;
             units: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$LIST_KEY_DEFS
  (          key_table_id: UNSIGNED;
             <modify> context: UNSIGNED;
             <modify> key_name: character string;
             VAR if_state: character string;
             VAR attributes: UNSIGNED;
             VAR equivalence_string: character string;
             VAR state_string: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$LIST_PASTEBOARD_ORDER
  (          display_id: UNSIGNED;
             <modify> context: UNSIGNED;
             VAR pasteboard_id: UNSIGNED;
             VAR pasteboard_row: INTEGER;
             VAR pasteboard_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$LIST_PASTING_ORDER
  (          pasteboard_id: UNSIGNED;
             <modify> context: UNSIGNED;
             VAR display_id: UNSIGNED;
             VAR pasteboard_row: INTEGER;
             VAR pasteboard_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$LOAD_KEY_DEFS
  (          key_table_id: UNSIGNED;
             filespec: character string;
             default_filespec: character string;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$LOAD_VIRTUAL_DISPLAY
  (          VAR display_id: UNSIGNED;
             filespec: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$MOVE_TEXT
  (          display_id: UNSIGNED;
             top_left_row: UNSIGNED;
             top_left_column: UNSIGNED;
             bottom_right_row: UNSIGNED;
             bottom_right_column: UNSIGNED;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$MOVE_VIRTUAL_DISPLAY
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER;
             top_display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$NAME_TO_KEYCODE
  (          key_name: character string;
             VAR key_code: word (unsigned);
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PASTE_VIRTUAL_DISPLAY
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER;
             top_display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$POP_VIRTUAL_DISPLAY
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PRINT_PASTEBOARD
  (          pasteboard_id: UNSIGNED;
             queue_name: character string;
             copies: INTEGER;
             form_name: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_CHARS
  (          display_id: UNSIGNED;
             text: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             flags: UNSIGNED;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_CHARS_HIGHWIDE
  (          display_id: UNSIGNED;
             text: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_CHARS_MULTI
  (          display_id: UNSIGNED;
             text: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             flags: UNSIGNED;
             rendition_string: character string;
             rendition_complement: character string;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_CHARS_WIDE
  (          display_id: UNSIGNED;
             text: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_HELP_TEXT
  (          display_id: UNSIGNED;
             keyboard_id: UNSIGNED;
             help_topic: character string;
             help_library: character string;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_LINE
  (          display_id: UNSIGNED;
             text: character string;
             line_advance: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             flags: UNSIGNED;
             character_set: UNSIGNED;
             direction: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_LINE_HIGHWIDE
  (          display_id: UNSIGNED;
             text: character string;
             line_advance: INTEGER;
             rendition_complement: UNSIGNED;
             flags: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_LINE_MULTI
  (          display_id: UNSIGNED;
             text: character string;
             rendition_string: character string;
             rendition_complement: character string;
             line_advance: INTEGER;
             flags: UNSIGNED;
             direction: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_LINE_WIDE
  (          display_id: UNSIGNED;
             text: character string;
             line_advance: INTEGER;
             rendition_complement: UNSIGNED;
             flags: UNSIGNED;
             character_set: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_PASTEBOARD
  (          pasteboard_id: UNSIGNED;
             action_routine: procedure value;
             user_argument: UNSIGNED;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$PUT_STATUS_LINE
  (          pasteboard_id: UNSIGNED;
             text: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$READ_COMPOSED_LINE
  (          keyboard_id: UNSIGNED;
             key_table_id: UNSIGNED;
             VAR resultant_string: character string;
             prompt_string: character string;
             VAR resultant_length: word (unsigned);
             display_id: UNSIGNED;
             flags: UNSIGNED;
             initial_string: character string;
             timeout: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             VAR word_terminator_code: word (unsigned);
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$READ_FROM_DISPLAY
  (          display_id: UNSIGNED;
             VAR resultant_string: character string;
             terminator_string: character string;
             start_row: INTEGER;
             VAR rendition_string: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$READ_KEYSTROKE
  (          keyboard_id: UNSIGNED;
             VAR word_terminator_code: word (unsigned);
             prompt_string: character string;
             timeout: INTEGER;
             display_id: UNSIGNED;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$READ_LOCATOR
  (          keyboard_id: UNSIGNED;
             row_number: word (unsigned);
             column_number: word (unsigned);
             VAR word_terminator_code: word (unsigned);
             timeout: INTEGER;
             parse_routine: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$READ_STRING
  (          keyboard_id: UNSIGNED;
             VAR resultant_string: character string;
             prompt_string: character string;
             maximum_length: INTEGER;
             modifiers: UNSIGNED;
             timeout: INTEGER;
             terminator_set: unspecified;
             VAR resultant_length: word (unsigned);
             VAR word_terminator_code: word (unsigned);
             display_id: UNSIGNED;
             initial_string: character string;
             rendition_complement: UNSIGNED;
             VAR terminator_string: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$READ_VERIFY
  (          keyboard_id: UNSIGNED;
             VAR resultant_string: character string;
             initial_string: character string;
             picture_string: character string;
             fill_character: character string;
             clear_character: character string;
             prompt_string: character string;
             modifiers: UNSIGNED;
             timeout: INTEGER;
             placeholder_arg: unspecified;
             initial_offset: INTEGER;
             VAR word_terminator_code: word (unsigned);
             display_id: UNSIGNED;
             alternate_echo_string: character string;
             alternate_display_id: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             VAR input_length: word (unsigned);
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$REMOVE_LINE
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             end_row: INTEGER;
             end_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$REPAINT_LINE
  (          pasteboard_id: UNSIGNED;
             start_row: INTEGER;
             number_of_lines: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$REPAINT_SCREEN
  (          pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$REPASTE_VIRTUAL_DISPLAY
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER;
             top_display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$REPLACE_INPUT_LINE
  (          keyboard_id: UNSIGNED;
             replace_string: character string;
             line_count: byte (unsigned);
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$RESTORE_PHYSICAL_SCREEN
  (          pasteboard_id: UNSIGNED;
             display_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$RETURN_CURSOR_POS
  (          display_id: UNSIGNED;
             VAR start_row: INTEGER;
             VAR start_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$RETURN_INPUT_LINE
  (          keyboard_id: UNSIGNED;
             VAR resultant_string: character string;
             match_string: character string;
             byte_integer_line_number: byte (unsigned);
             VAR resultant_length: word (unsigned);
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$RING_BELL
  (          display_id: UNSIGNED;
             number_of_times: longword integer (signed);
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SAVE_PHYSICAL_SCREEN
  (          pasteboard_id: UNSIGNED;
             VAR display_id: UNSIGNED;
             desired_start_row: INTEGER;
             desired_end_row: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SAVE_VIRTUAL_DISPLAY
  (          display_id: UNSIGNED;
             filespec: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SCROLL_DISPLAY_AREA
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             height: INTEGER;
             width: INTEGER;
             direction: UNSIGNED;
             count: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SCROLL_VIEWPORT
  (          display_id: UNSIGNED;
             direction: UNSIGNED;
             count: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SELECT_FROM_MENU
  (          keyboard_id: UNSIGNED;
             display_id: UNSIGNED;
             VAR selected_choice_number: word (unsigned);
             default_choice_number: word (unsigned);
             flags: UNSIGNED;
             help_library: character string;
             timeout: INTEGER;
             VAR word_terminator_code: word (unsigned);
             VAR selected_choice_string: character string;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_BROADCAST_TRAPPING
  (          pasteboard_id: UNSIGNED;
             AST_routine: procedure value;
             AST_argument: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_CURSOR_ABS
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_CURSOR_MODE
  (          pasteboard_id: UNSIGNED;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_CURSOR_REL
  (          display_id: UNSIGNED;
             delta_row: INTEGER;
             delta_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_DEFAULT_STATE
  (          key_table_id: UNSIGNED;
             new_state: character string;
             VAR old_state: character string;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_DISPLAY_SCROLL_REGION
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             end_row: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_KEYPAD_MODE
  (          keyboard_id: UNSIGNED;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_OUT_OF_BAND_ASTS
  (          pasteboard_id: UNSIGNED;
             control_character_mask: UNSIGNED;
             AST_routine: procedure value;
             AST_argument: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_PHYSICAL_CURSOR
  (          pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SET_TERM_CHARACTERISTICS
  (          pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SNAPSHOT
  (          pasteboard_id: UNSIGNED;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$SNAPSHOT_TO_PRINTER
  (          pasteboard_id: UNSIGNED;
             device_type: character string;
             flags: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS,UNBOUND]FUNCTION SMG$UNPASTE_VIRTUAL_DISPLAY
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
   )
      : UNSIGNED;
        EXTERNAL;



END.
