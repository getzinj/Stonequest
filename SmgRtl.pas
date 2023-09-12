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

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$add_key_def
  (          key_table_id: UNSIGNED;
             key_name: VARYING [$len2] OF CHAR;
             if_state: VARYING [$len3] OF CHAR := %immed 0;
             attributes: UNSIGNED := %immed 0;
             equivalence_string: VARYING [$len5] OF CHAR := %immed 0;
             state_string: VARYING [$len6] OF CHAR := %immed 0 ) : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$allow_escape
  (          display_id: UNSIGNED;
             esc_flag: UNSIGNED)
        : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$begin_display_update
  (          display_id: UNSIGNED )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$begin_pasteboard_update
  (          pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$cancel_input
  (          keyboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$change_pbd_characteristics
  (          pasteboard_id: UNSIGNED;
             desired_width: INTEGER := %immed 0;
   VAR       resulting_width: INTEGER := %immed 0;
             desired_height: INTEGER := %immed 0;
   VAR       resulting_height: INTEGER := %immed 0;
             desired_background_color: UNSIGNED := %immed 0;
   VAR       resulting_background_color: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$change_rendition
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             number_of_rows: INTEGER;
             number_of_columns: INTEGER;
             rendition_set: UNSIGNED := %immed 0;
             rendition_complement: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$CHANGE_VIEWPORT(%Ref display_ID: UNSIGNED; %Ref viewport_row_Start, viewport_column_start: INTEGER;
             %Ref viewport_number_rows, viewport_number_columns: INTEGER := %immed 0):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$change_virtual_display
  (          display_id: UNSIGNED;
             number_of_rows: INTEGER;
             number_of_columns: INTEGER;
             display_attributes: UNSIGNED := %immed 0;
             video_attributes: UNSIGNED := %immed 0;
             character_set: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$check_for_occlusion
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
   VAR       occlusion_state: INTEGER )
      : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$control_mode
  (          pasteboard_id: UNSIGNED;
             new_mode: UNSIGNED := %immed 0;
   VAR       old_mode: UNSIGNED := %immed 0)
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$COPY_VIRTUAL_DISPLAY(%Ref current_display_ID, new_display_ID: Unsigned): Unsigned;External;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$create_key_table
  (          VAR key_table_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION SMG$CREATE_MENU
  (%Ref          display_id: UNSIGNED;
   %Descr        choices: Packed Array [$A1..$A2: Integer] of Char;
   %Ref          menu_type: UNSIGNED := %immed 0;
   %Ref          flags: UNSIGNED := %immed 0;
   %Ref          row: INTEGER := %immed 0;
   %Ref          rendition_set: UNSIGNED := %immed 0;
   %Ref          rendition_complement: UNSIGNED := %immed 0):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$create_pasteboard
  (VAR       pasteboard_id: UNSIGNED;
             output_device: VARYING [$len2] OF CHAR := %immed 0;
   VAR       number_of_pasteboard_rows: INTEGER := %immed 0;
   VAR       number_of_pasteboard_columns: INTEGER := %immed 0;
             flags: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
Function SMG$CREATE_SUBPROCESS
  (          %Ref display_id: UNSIGNED;
                  AST_routine,AST_argument: Integer := %immed 0 )
      : Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$create_virtual_display
  (          number_of_rows: INTEGER;
             number_of_columns: INTEGER;
   VAR       display_id: UNSIGNED;
             display_attributes: UNSIGNED := %immed 0;
             video_attributes: UNSIGNED := %immed 0;
             character_set: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$create_virtual_keyboard
  (          VAR keyboard_id: UNSIGNED;
             input_device: VARYING [$len2] OF CHAR := %immed 0;
             default_filespec: VARYING [$len3] OF CHAR := %immed 0;
   VAR       resultant_filespec: VARYING [$len4] OF CHAR := %immed 0;
             recall_size: byte (unsigned) := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$cursor_column
  (          display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$cursor_row
  (          display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$define_key
  (          key_table_id: UNSIGNED;
             command_string: VARYING [$len2] of CHAR )
      : UNSIGNED;

        EXTERNAL;


[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$del_term_table : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$delete_chars
  (          display_id: UNSIGNED;
             number_of_characters: INTEGER;
             start_row: INTEGER;
             start_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$delete_key_def
  (          key_table_id: UNSIGNED;
             key_name: VARYING [$len2] OF CHAR;
             if_state: VARYING [$len3] OF CHAR := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$delete_line
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             number_of_rows: INTEGER := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$DELETE_MENU ( %Ref display_ID: UNSIGNED; %Ref flags: UNSIGNED:=%Immed 0):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$delete_pasteboard
  (          pasteboard_id: UNSIGNED;
             flags: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$DELETE_SUBPROCESS(%Ref display_ID: UNSIGNED):Unsigned;External
[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$DELETE_VIEWPORT(%Ref display_ID: UNSIGNED):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$delete_virtual_display
  (          display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$delete_virtual_keyboard
  (          keyboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;


[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$DISABLE_BROADCAST_TRAPPING(%Ref pasteboard_id: UNSIGNED):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$disable_unsolicited_input
  (          pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$DRAW_CHAR (%Ref display_id, Flags: UNSIGNED;
             %Ref row, column: INTEGER := %immed 0;
             %Ref rendition_set: UNSIGNED := %immed 0;
             %Ref rendition_complement: UNSIGNED := %immed 0 ): Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$draw_line
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             end_row: INTEGER;
             end_column: INTEGER;
             rendition_set: UNSIGNED := %immed 0;
             rendition_complement: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$draw_rectangle
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             end_row: INTEGER;
             end_column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$enable_unsolicited_input
  (          pasteboard_id: UNSIGNED;
   %immed          [UNBOUND] PROCEDURE ast_routine := %immed 0;
   %immed          AST_argument: [UNSAFE] UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$end_display_update
  (          display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$end_pasteboard_update
  (          pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$erase_chars
  (          display_id: UNSIGNED;
             number_of_characters: INTEGER;
             start_row: INTEGER;
             start_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$ERASE_COLUMN (
%Ref Display_ID: UNSIGNED;
%Ref Start_Row,Column_Number,End_Row: INTEGER := %Immed 0):Unsigned;external;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$erase_display
  (          display_id: UNSIGNED;
             start_row: INTEGER := %Immed 0;
             start_column: INTEGER := %Immed 0;
             end_row: INTEGER := %Immed 0;
             end_column: INTEGER := %Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$erase_line
  (          display_id: UNSIGNED;
             start_row: INTEGER := %Immed 0;
             start_column: INTEGER := %Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$erase_pasteboard
  (          pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$EXECUTE_COMMAND
  (%Ref Display_ID: UNSIGNED;
   %Descr Command_Desc: Varying [$K1] of Char;
   %Ref flags,ret_status: Unsigned := %Immed 0 ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$find_cursor_display
  (          pasteboard_id: UNSIGNED;
   VAR       returned_display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$flush_buffer
  (          pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$get_broadcast_message
  (          pasteboard_id: UNSIGNED;
   VAR       message: VARYING [$len2] OF CHAR := %Immed 0;
   VAR       message_length: $word := %immed 0)
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$get_char_at_physical_cursor
  (          pasteboard_id: UNSIGNED;
   VAR       character: byte (unsigned) )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$get_display_attr
  (          display_id: UNSIGNED;
   VAR       height: INTEGER;
   VAR       width: INTEGER;
   VAR       display_attributes: UNSIGNED := %immed 0;
   VAR       video_attributes: UNSIGNED := %immed 0;
             character_set: UNSIGNED := %immed 0)
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$get_keyboard_attributes
  (          keyboard_id: UNSIGNED;
   VAR       keyboard_info_table: unspecified;
             keyboard_info_table_size: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$get_key_def
  (          key_table_id: UNSIGNED;
             key_name: character string;
             if_state: character string;
   VAR       attributes: UNSIGNED;
   VAR       equivalence_string: character string;
   VAR       state_string: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$get_numeric_data
  (          termtable_address: UNSIGNED;
             request_code: UNSIGNED;
   VAR       buffer_address: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$get_pasteboard_attributes
  (          pasteboard_id: UNSIGNED;
   VAR       pasteboard_info_table: unspecified;
             pasteboard_info_table_size: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$get_pasting_info
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
   VAR       flags: UNSIGNED;
   VAR       pasteboard_row: INTEGER;
   VAR       pasteboard_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$get_term_data
  (          termtable_address: UNSIGNED;
             request_code: INTEGER;
             maximum_buffer_length: INTEGER;
   VAR       return_length: INTEGER;
             <by reference, array reference> capability_data: unspecified;
             input_argument_vector: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$get_viewport_char
  (          display_id: UNSIGNED;
   VAR       viewport_row_start: INTEGER;
   VAR       viewport_column_start: INTEGER;
   VAR       viewport_number_rows: INTEGER;
   VAR       viewport_number_columns: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$home_cursor
  (          display_id: UNSIGNED;
             position_code: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$init_term_table
  (          terminal_name: character string;
   VAR       termtable_address: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$init_term_table_by_type
  (          terminal_type: $byte;
   VAR       termtable_address: UNSIGNED;
   VAR       terminal_name: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$insert_chars
  (          display_id: UNSIGNED;
             character_string: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$insert_line
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             character_string: character string;
             direction: UNSIGNED;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             flags: UNSIGNED;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$invalidate_display
  (          display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$keycode_to_name
  (          key_code: word (unsigned);
   VAR       key_name: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$label_border
  (          display_id: UNSIGNED;
             text: character string;
             position_code: UNSIGNED;
             units: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$list_key_defs
  (          key_table_id: UNSIGNED;
             <modify> context: UNSIGNED;
             <modify> key_name: character string;
   VAR       if_state: character string;
   VAR       attributes: UNSIGNED;
   VAR       equivalence_string: character string;
   VAR       state_string: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$list_pasteboard_order
  (          display_id: UNSIGNED;
             <modify> context: UNSIGNED;
   VAR       pasteboard_id: UNSIGNED;
   VAR       pasteboard_row: INTEGER;
   VAR       pasteboard_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$list_pasting_order
  (          pasteboard_id: UNSIGNED;
             <modify> context: UNSIGNED;
   VAR       display_id: UNSIGNED;
   VAR       pasteboard_row: INTEGER;
   VAR       pasteboard_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$load_key_defs
  (          key_table_id: UNSIGNED;
             filespec: character string;
             default_filespec: character string;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$load_virtual_display
  (          VAR display_id: UNSIGNED;
             filespec: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$move_text
  (          display_id: UNSIGNED;
             top_left_row: UNSIGNED;
             top_left_column: UNSIGNED;
             bottom_right_row: UNSIGNED;
             bottom_right_column: UNSIGNED;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$move_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER;
             top_display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$name_to_keycode
  (          key_name: character string;
   VAR       key_code: word (unsigned) )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$paste_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER;
             top_display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$pop_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$print_pasteboard
  (          pasteboard_id: UNSIGNED;
             queue_name: character string;
             copies: INTEGER;
             form_name: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_chars
  (          display_id: UNSIGNED;
             text: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             flags: UNSIGNED;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_chars_highwide
  (          display_id: UNSIGNED;
             text: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_chars_multi
  (          display_id: UNSIGNED;
             text: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             flags: UNSIGNED;
             rendition_string: character string;
             rendition_complement: character string;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_chars_wide
  (          display_id: UNSIGNED;
             text: character string;
             start_row: INTEGER;
             start_column: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_help_text
  (          display_id: UNSIGNED;
             keyboard_id: UNSIGNED;
             help_topic: character string;
             help_library: character string;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_line
  (          display_id: UNSIGNED;
             text: character string;
             line_advance: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
             flags: UNSIGNED;
             character_set: UNSIGNED;
             direction: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_line_highwide
  (          display_id: UNSIGNED;
             text: character string;
             line_advance: INTEGER;
             rendition_complement: UNSIGNED;
             flags: UNSIGNED;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_line_multi
  (          display_id: UNSIGNED;
             text: character string;
             rendition_string: character string;
             rendition_complement: character string;
             line_advance: INTEGER;
             flags: UNSIGNED;
             direction: UNSIGNED;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_line_wide
  (          display_id: UNSIGNED;
             text: character string;
             line_advance: INTEGER;
             rendition_complement: UNSIGNED;
             flags: UNSIGNED;
             character_set: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_pasteboard
  (          pasteboard_id: UNSIGNED;
             action_routine: procedure value;
             user_argument: UNSIGNED;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$put_status_line
  (          pasteboard_id: UNSIGNED;
             text: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$read_composed_line
  (          keyboard_id: UNSIGNED;
             key_table_id: UNSIGNED;
   VAR       resultant_string: character string;
             prompt_string: character string;
   VAR       resultant_length: word (unsigned);
             display_id: UNSIGNED;
             flags: UNSIGNED;
             initial_string: character string;
             timeout: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
   VAR       word_terminator_code: word (unsigned) )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$read_from_display
  (          display_id: UNSIGNED;
   VAR       resultant_string: character string;
             terminator_string: character string;
             start_row: INTEGER;
   VAR       rendition_string: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$read_keystroke
  (          keyboard_id: UNSIGNED;
   VAR       word_terminator_code: word (unsigned);
             prompt_string: character string;
             timeout: INTEGER;
             display_id: UNSIGNED;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$read_locator
  (          keyboard_id: UNSIGNED;
             row_number: word (unsigned);
             column_number: word (unsigned);
   VAR       word_terminator_code: word (unsigned);
             timeout: INTEGER;
             parse_routine: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$read_string
  (          keyboard_id: UNSIGNED;
   VAR       resultant_string: character string;
             prompt_string: character string;
             maximum_length: INTEGER;
             modifiers: UNSIGNED;
             timeout: INTEGER;
             terminator_set: unspecified;
   VAR       resultant_length: word (unsigned);
   VAR       word_terminator_code: word (unsigned);
             display_id: UNSIGNED;
             initial_string: character string;
             rendition_complement: UNSIGNED;
   VAR       terminator_string: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$read_verify
  (          keyboard_id: UNSIGNED;
   VAR       resultant_string: character string;
             initial_string: character string;
             picture_string: character string;
             fill_character: character string;
             clear_character: character string;
             prompt_string: character string;
             modifiers: UNSIGNED;
             timeout: INTEGER;
             placeholder_arg: unspecified;
             initial_offset: INTEGER;
   VAR       word_terminator_code: word (unsigned);
             display_id: UNSIGNED;
             alternate_echo_string: character string;
             alternate_display_id: INTEGER;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED;
   VAR       input_length: word (unsigned) )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$remove_line
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             end_row: INTEGER;
             end_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$repaint_line
  (          pasteboard_id: UNSIGNED;
             start_row: INTEGER;
             number_of_lines: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$repaint_screen
  (          pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$repaste_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER;
             top_display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$replace_input_line
  (          keyboard_id: UNSIGNED;
             replace_string: character string;
             line_count: byte (unsigned);
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$restore_physical_screen
  (          pasteboard_id: UNSIGNED;
             display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$return_cursor_pos
  (          display_id: UNSIGNED;
   VAR       start_row: INTEGER;
   VAR       start_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$return_input_line
  (          keyboard_id: UNSIGNED;
   VAR       resultant_string: character string;
             match_string: character string;
             byte_integer_line_number: byte (unsigned);
   VAR       resultant_length: word (unsigned) )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$ring_bell
  (          display_id: UNSIGNED;
             number_of_times: longword integer (signed) )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$save_physical_screen
  (          pasteboard_id: UNSIGNED;
   VAR       display_id: UNSIGNED;
             desired_start_row: INTEGER;
             desired_end_row: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$save_virtual_display
  (          display_id: UNSIGNED;
             filespec: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$scroll_display_area
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER;
             height: INTEGER;
             width: INTEGER;
             direction: UNSIGNED;
             count: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$scroll_viewport
  (          display_id: UNSIGNED;
             direction: UNSIGNED;
             count: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$select_from_menu
  (          keyboard_id: UNSIGNED;
             display_id: UNSIGNED;
   VAR       selected_choice_number: word (unsigned);
             default_choice_number: word (unsigned);
             flags: UNSIGNED;
             help_library: character string;
             timeout: INTEGER;
   VAR       word_terminator_code: word (unsigned);
   VAR       selected_choice_string: character string;
             rendition_set: UNSIGNED;
             rendition_complement: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_broadcast_trapping
  (          pasteboard_id: UNSIGNED;
             AST_routine: procedure value;
             AST_argument: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_cursor_abs
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_cursor_mode
  (          pasteboard_id: UNSIGNED;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_cursor_rel
  (          display_id: UNSIGNED;
             delta_row: INTEGER;
             delta_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_default_state
  (          key_table_id: UNSIGNED;
             new_state: character string;
   VAR       old_state: character string )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_display_scroll_region
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             end_row: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_keypad_mode
  (          keyboard_id: UNSIGNED;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_out_of_band_asts
  (          pasteboard_id: UNSIGNED;
             control_character_mask: UNSIGNED;
             AST_routine: procedure value;
             AST_argument: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_physical_cursor
  (          pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$set_term_characteristics
  (          pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$snapshot
  (          pasteboard_id: UNSIGNED;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$snapshot_to_printer
  (          pasteboard_id: UNSIGNED;
             device_type: character string;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION smg$unpaste_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;



END.
