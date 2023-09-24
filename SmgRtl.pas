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
             recall_size: $Ubyte := %immed 0 )
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

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$DELETE_SUBPROCESS(%Ref display_ID: UNSIGNED):Unsigned;External;
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
   VAR       character: $Ubyte )
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

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$GET_KEYBOARD_ATTRIBUTES (
%Ref Keyboard_ID,P_Kit,P_Kit_Size: Unsigned):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$get_key_def
  (          key_table_id: UNSIGNED;
             key_name: VARYING [$len2] OF CHAR;
             if_state: VARYING [$len3] OF CHAR := %immed 0;
   VAR       attributes: UNSIGNED := %immed 0;
   VAR       equivalence_string: VARYING [$len5] OF CHAR := %immed 0;
   VAR       state_string: VARYING [$len6] OF CHAR := %immed 0)
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$get_numeric_data
  (          termtable_address: UNSIGNED;
             request_code: UNSIGNED;
   VAR       buffer_address: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$get_pasteboard_attributes
  (          pasteboard_id: UNSIGNED;
   VAR       pasteboard_info_table: ARRAY [$l2..$h2: INTEGER] of $ubyte;
             pasteboard_info_table_size: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$GET_PASTING_INFO (
%Ref Display_ID,Pasteboard,Flags: Unsigned;
%Ref Pasteboard_Row,Pasteboard_Column: Integer := %immed 0 ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$get_term_data
  (          termtable_address: UNSIGNED;
             request_code: INTEGER;
             maximum_buffer_length: INTEGER;
   VAR       return_length: INTEGER;
             buffer_address: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$GET_VIEWPORT_CHAR(
%Ref Display_ID: Unsigned;
%Ref Viewport_Row_Start,Viewport_Column_Start: Integer := %immed 0;
%Ref Viewport_Number_Rows,Viewport_Number_Columns: Integer := %immed 0 ):
Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$home_cursor
  (          display_id: UNSIGNED;
             position_code: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$init_term_table
  (          terminal_name: VARYING [$len1] OF CHAR;
   VAR       termtable_address: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$init_term_table_by_type
  (          terminal_type: $byte;
   VAR       termtable_address: UNSIGNED;
   VAR       terminal_name: VARYING [$len3] OF CHAR := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$insert_chars
  (          display_id: UNSIGNED;
             string: VARYING [$len2] OF CHAR;
             row: INTEGER;
             column: INTEGER;
             rendition_set: UNSIGNED := %immed 0;
             rendition_complement: UNSIGNED := %immed 0;
             character_set: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$insert_line
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             character_string: VARYING [$len3] OF CHAR := %immed 0;
             direction: UNSIGNED := %immed 0;
             rendition_set: UNSIGNED := %immed 0;
             rendition_complement: UNSIGNED := %immed 0;
             flags: UNSIGNED := %immed 0;
             character_set: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$invalidate_display
  (          display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$KEYCODE_TO_NAME
(%Ref Key_Code: $Word;
%Descr Key_Name: Varying [$G1] of Char):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$label_border
  (          display_id: UNSIGNED;
             label_text: VARYING [$len2] OF CHAR := %immed 0;
             position: UNSIGNED := %immed 0;
             units: INTEGER := %immed 0;
             rendition_set: UNSIGNED := %immed 0;
             rendition_complement: UNSIGNED := %immed 0;
             character_set: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$list_key_defs
  (          key_table_id: UNSIGNED;
   %Ref      context: INTEGER;
   VAR       key_name: VARYING [$len3] OF CHAR := %immed 0;
   VAR       if_state: VARYING [$len4] OF CHAR := %immed 0;
   VAR       attributes: UNSIGNED := %immed 0;
   VAR       equivalence_string: VARYING [$len6] OF CHAR := %immed 0;
   VAR       state_string: VARYING [$len7] OF CHAR := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION SMG$LIST_PASTING_ORDER (
%Ref Pasteboard_ID,Context,Display_ID: UNSIGNED;
%Ref Pasteboard_Row,Pasteboard_Column: INTEGER := %immed 0 ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$load_key_defs
  (          key_table_id: UNSIGNED;
             filespec: VARYING [$len2] OF CHAR;
             default_filespec: VARYING [$len3] OF CHAR := %immed 0;
             lognam_flag: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
Function SMG$LOAD_VIRTUAL_DISPLAY
(%Ref Display_ID: UNSIGNED;
%Descr File_Spec: Varying [$M1] of Char:=%Immed 0):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]Function SMG$MOVE_TEXT (
%Ref Display_ID,Top_Left_Row,Top_Left_Column,Bottom_Right_Row,Bottom_Right_Column: UNSIGNED;
%Ref Display_ID2: Unsigned;
%Ref Top_Left_Row2,Top_Left_Column2,Flags: Unsigned:=%Immed 0): Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$move_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER)
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$NAME_TO_KEYCODE (
%Descr Key_Name: Varying [$k1] of Char;
%Ref Key_Code: $Word): Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$paste_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$pop_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$PRINT_PASTEBOARD (
%Ref Pasteboard_ID: UNSIGNED;
%Descr Queue_Name: Varying [$J1] of Char := %Immed 0;
%Ref copies: Integer := %Immed 0): Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$put_chars
  (          display_id: UNSIGNED;
             text: VARYING [$len2] OF CHAR;
             start_row: INTEGER := %immed 0;
             start_column: INTEGER := %immed 0;
             flags: UNSIGNED := %immed 0;
             rendition_set: UNSIGNED := %immed 0;
             rendition_complement: UNSIGNED := %immed 0;
             character_set: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$put_chars_highwide
  (          display_id: UNSIGNED;
             text: VARYING [$len2] OF CHAR;
             start_row: INTEGER := %immed 0;
             start_column: INTEGER := %immed 0;
             rendition_set: UNSIGNED := %immed 0;
             rendition_complement: UNSIGNED := %immed 0;
             character_set: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$PUT_CHARS_MULTI (
%Ref Display_ID: Unsigned;
%Descr text: Varying [$I1] of Char;
%Ref start_row,start_column: INTEGER := %Immed 0;
%Ref flags: UNSIGNED := %Immed 0;
%Descr rendition_string: Varying [$I2] of Char := %Immed 0;
%Descr rendition_complement: Varying [$I3] of Char := %Immed 0;
%Ref character_set: UNSIGNED := %Immed 0 ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$put_chars_wide
  (          display_id: UNSIGNED;
             text: VARYING [$len2] OF CHAR;
             start_row: INTEGER := %Immed 0;
             start_column: INTEGER := %Immed 0;
             rendition_set: UNSIGNED := %Immed 0;
             rendition_complement: UNSIGNED := %Immed 0;
             character_set: UNSIGNED := %Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$PUT_HELP_TEXT (
%Ref Display_ID: UNSIGNED;
%Ref Keyboard_ID: UNSIGNED := %Immed 0;
%Descr help_topic: VARYING [$H1] OF CHAR := %Immed 0;
%Descr help_library: VARYING [$H2] OF CHAR := %Immed 0;
%Ref rendition_set: UNSIGNED := %Immed 0;
%Ref rendition_complement: UNSIGNED := %Immed 0 ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$put_line
  (          display_id: UNSIGNED;
             text: VARYING [$len2] OF CHAR;
             line_advance: INTEGER := %Immed 0;
             rendition_set: UNSIGNED := %Immed 0;
             rendition_complement: UNSIGNED := %Immed 0;
             wrap_flag: UNSIGNED := %Immed 0;
             character_set: UNSIGNED := %Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$put_line_highwide
  (          display_id: UNSIGNED;
             text: VARYING [$len2] OF CHAR;
             line_advance: INTEGER := %Immed 0;
             rendition_complement: UNSIGNED := %Immed 0;
             wrap_flag: UNSIGNED := %Immed 0;
             character_set: UNSIGNED := %Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$PUT_LINE_MULTI (
%Ref display_id: UNSIGNED;
%Descr text: VARYING [$W1] OF CHAR;
%Descr rendition_string: VARYING [$W2] OF CHAR := %Immed 0;
%Descr rendition_complement: VARYING [$W3] OF CHAR := %Immed 0;
%Ref line_advance: INTEGER := %Immed 0;
%Ref wrap_flag: UNSIGNED := %Immed 0;
%Ref direction: UNSIGNED := %Immed 0;
%Ref character_set: UNSIGNED := %Immed 0 ): UNSIGNED; EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$put_line_wide
  (          display_id: UNSIGNED;
             text: VARYING [$len2] OF CHAR;
             line_advance: INTEGER := %Immed 0;
             rendition_complement: UNSIGNED := %Immed 0;
             flags: UNSIGNED := %Immed 0;
             character_set: UNSIGNED := %Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$put_pasteboard
  (          pasteboard_id: UNSIGNED;
   %immed    [UNBOUND] PROCEDURE P_rtn;
             user_argument: UNSIGNED;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$PUT_STATUS_LINE (%Ref Pasteboard_ID: UNSIGNED;
%Descr Text: VARYING [$X9] OF CHAR ) : UNSIGNED; EXTERNAL;


[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$put_virtual_display_encoded
  (          display_id: UNSIGNED;
             encoded_length: UNSIGNED;
   %Ref      encoded_text: ARRAY [$l3..$h3: INTEGER] of $ubyte;
             line_number: INTEGER := %immed 0;
             column_number: INTEGER := %immed 0;
             wrap_flag: UNSIGNED := %immed 0;
             char_set: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$put_input_with_scroll
  (          display_id: UNSIGNED;
             text: VARYING [$len2] OF CHAR := %immed 0;
             direction: UNSIGNED := %immed 0;
             rendition_set: UNSIGNED := %immed 0;
             rendition_complement: UNSIGNED := %immed 0;
             wrap_flag: UNSIGNED := %immed 0;
             char_set: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$read_composed_line
  (          keyboard_id: UNSIGNED;
             key_table_id: UNSIGNED;
   VAR       resultant_string: VARYING [$len3] OF CHAR;
             prompt_string: VARYING [$len4] OF CHAR := %immed 0;
   VAR       resultant_length: $Word := %immed 0;
             display_id: UNSIGNED := %immed 0;
             function_keys: UNSIGNED := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$read_from_display
  (          display_id: UNSIGNED;
   VAR       resultant_string: VARYING [$len2] OF CHAR;
             terminator_string: VARYING [$len3] OF CHAR := %immed 0;
             start_row: INTEGER := %immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$read_keystroke
  (%Ref      keyboard_id: UNSIGNED;
   %Ref      word_terminator_code: $Uword;
   %Descr    prompt_string: VARYING [$len3] OF CHAR := %immed 0;
   %Ref      timeout: INTEGER := %immed 0;
   %Ref      display_id: UNSIGNED := %immed 0;
   %Ref      rendition_set: UNSIGNED := %Immed 0;
   %Ref      rendition_complement: UNSIGNED := %Immed 0)
      : UNSIGNED;

        EXTERNAL;


[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$read_string
  (          keyboard_id: UNSIGNED;
   VAR       resultant_string: VARYING [$len2] OF CHAR;
             prompt_string: VARYING [$len3] OF CHAR := %Immed 0;
             maximum_length: INTEGER := %Immed 0;
             modifiers: UNSIGNED := %Immed 0;
             timeout: INTEGER := %Immed 0;
             terminator_set: [CLASS_S]
                             PACKED ARRAY [$l7..$h7 : INTEGER] OF $ubyte := %Immed 0;
   VAR       resultant_length: $Word := %Immed 0;
   VAR       word_terminator_code: $Word := %Immed 0;
             display_id: UNSIGNED := %Immed 0;
             initial_string: VARYING [$Len11] OF CHAR := %Immed 0;
             rendition_set: UNSIGNED := %Immed 0;
             rendition_complement: UNSIGNED := %Immed 0;
   VAR       terminator_string: VARYING [$Len21] OF CHAR := %Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$read_verify
  (          keyboard_id: UNSIGNED;
   VAR       resultant_string: VARYING [$len2] OF CHAR;
             initial_string: VARYING [$len3] OF CHAR;
             picture_string: VARYING [$len4] OF CHAR;
             fill_character: VARYING [$len5] OF CHAR;
             clear_character: VARYING [$len6] OF CHAR;
             prompt_string: VARYING [$len7] OF CHAR;
             modifiers: UNSIGNED;
             timeout: INTEGER;
             terminator_set: [CLASS_S]
                                          PACKED ARRAY [$l7..$h7 : INTEGER] OF $ubyte := %Immed 0;
             initial_offset: INTEGER := %Immed 0;
   VAR       word_terminator_code: $Word := %Immed 0;
             display_id: UNSIGNED := %Immed 0;
             alternate_echo_string: VARYING [$len14] OF CHAR := %Immed 0;
             alternate_display_id: INTEGER := %Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$REMOVE_LINE (
%Ref Display_ID: UNSIGNED;
%Ref Start_Row,Start_Column,End_Row,End_Column: INTEGER ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$repaint_line
  (          pasteboard_id: UNSIGNED;
             start_row: INTEGER;
             number_of_lines: INTEGER:=%Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$repaint_screen
  (          pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$repaste_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER;
             top_display_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$REPLACE_INPUT_LINE (
%Ref keyboard_id: UNSIGNED;
%Descr replace_string: Varying [$Z7] of Char:=%Immed 0;
%Ref line_count: $Ubyte:=%Immed 0 ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$return_cursor_pos
  (          display_id: UNSIGNED;
   VAR       start_row: INTEGER;
   VAR       start_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$RETURN_INPUT_LINE(
%Ref Keyboard_ID: UNSIGNED;
%Descr resultant_string: Varying [$Z4] of Char;
%Descr match_string: Varying [$Z5] of Char:=%Immed 0;
%Ref byte_integer_line_number: $Ubyte:=%Immed 0;
%Ref resultant_length: $Word:=%Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$ring_bell
  (          display_id: UNSIGNED;
             number_of_times: Integer :=%immed 0)
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$save_physical_screen
  (          pasteboard_id: UNSIGNED;
   VAR       display_id: UNSIGNED;
             desired_start_row: INTEGER:=%Immed 0;
             desired_end_row: INTEGER:=%Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$SAVE_VIRTUAL_DISPLAY (
%Ref Display_ID: UNSIGNED;
%Descr File_Spec: Varying [$Z3] of Char ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$scroll_display_area
  (          display_id: UNSIGNED;
             start_row: INTEGER;
             start_column: INTEGER:=%Immed 0;
             height: INTEGER:=%Immed 0;
             width: INTEGER:=%Immed 0;
             direction: UNSIGNED:=%Immed 0;
             count: INTEGER:=%Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]Function SMG$SCROLL_VIEWPORT (
%Ref Display_ID: UNSIGNED;
%Ref direction: UNSIGNED:=%Immed 0;
%Ref count: INTEGER:=%Immed 0 ):Unsigned;External;

Function SMG$SELECT_FROM_MENU (%Ref Keyboard_ID,Display_ID: Unsigned;
                               %Ref Selected_Choice_number: $Uword;
                               %Ref default_choice_number: $Uword:=%Immed 0;
                               %Ref flags: UNSIGNED:=%Immed 0;
                               %Descr help_library: VARYING [$Z1] OF CHAR:=%Immed 0;
                               %Ref Timeout: INTEGER:=%Immed 0;
                               %Ref word_terminator_code: $Word:=%Immed 0;
                               %Descr selected_choice_string: VARYING [$Z2] OF CHAR:=%Immed 0;
                               %Ref rendition_set,rendition_complement: UNSIGNED:=%Immed 0 ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$set_broadcast_trapping
  (          pasteboard_id: UNSIGNED;
   %immed    [UNBOUND] Procedure ast_routine:=%immed 0;
   %immed    ast_argument: UNSIGNED:=%immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$set_cursor_abs
  (          display_id: UNSIGNED;
             start_row: INTEGER:=%immed 0;
             start_column: INTEGER:=%immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]function SMG$SET_CURSOR_MODE (%Ref Pasteboard_ID,flags: UNSIGNED ):Unsigned;External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$set_cursor_rel
  (          display_id: UNSIGNED;
             delta_row: INTEGER:=%immed 0;
             delta_column: INTEGER:=%immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$set_default_state
  (          key_table_id: UNSIGNED;
             new_state: VARYING [$len2] OF CHAR:=%Immed 0;
   VAR       old_state: VARYING [$len3] OF CHAR:=%Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$set_display_scroll_region
  (          display_id: UNSIGNED;
             start_row: INTEGER:=%Immed 0;
             end_row: INTEGER:=%Immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$set_keypad_mode
  (          keyboard_id: UNSIGNED;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$set_out_of_band_asts
  (          pasteboard_id: UNSIGNED;
             control_character_mask: UNSIGNED;
   %Immed    [UNBOUND] PROCEDURE ast_routine:=%immed 0;
   %Immed    ast_argument: UNSIGNED:=%immed 0 )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$set_physical_cursor
  (          pasteboard_id: UNSIGNED;
             pasteboard_row: INTEGER;
             pasteboard_column: INTEGER )
      : UNSIGNED;

        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]function SMG$SET_TERM_CHARACTERISTICS (
%Ref Pasteboard_ID: UNSIGNED;
%Ref On_Characteristics1,On_Characteristics2: Unsigned:=%Immed 0;
%Ref Off_Characteristics1,Off_Characteristics2: Unsigned:=%Immed 0;
%Ref Old_Characteristics1,Old_Characteristics2: Unsigned:=%Immed 0):Unsigned;
External;

[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$snapshot
  (          pasteboard_id: UNSIGNED;
             flags: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;


[ASYNCHRONOUS, UNBOUND]
FUNCTION smg$unpaste_virtual_display
  (          display_id: UNSIGNED;
             pasteboard_id: UNSIGNED )
      : UNSIGNED;

        EXTERNAL;

END.
