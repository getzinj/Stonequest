[Inherit ('SYS$LIBRARY:STARLET','LibRtl','Types','SMGRTL')]Module Windows;

Type
   Signed_Word = [Word]-32767..32767;
   Long_Line = Varying [390] of Char;

Var
   Print_Queue: [External]Line;
   Pasteboard: [External]Unsigned;
   Cursor_Mode,Broadcast_On: [External]Boolean;

(******************************************************************************)
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
(******************************************************************************)

Procedure Create_And_Label (Var Display_ID: Unsigned; Message_Text: Line);

Begin
   SMG$Create_Virtual_Display (5,78,Display_ID,1);
   SMG$Erase_Display (Display_ID);
   SMG$Label_Border (Display_ID,Message_Text,SMG$K_TOP);
End;

(******************************************************************************)

Procedure Strip_Controls (Var Msg: Long_Line);

Var
   X: Integer;

Begin
   If Msg.Length>0 then
      For X:=1 to Msg.Length do
         If (Ord(Msg[X])<32) then
            Msg[X]:=' ';
End;


(******************************************************************************)

[Global]Procedure Message_Trap;

Var
   BroadcastDisplay: Unsigned;  { Virtual Display }
   Msg: Varying [390] of Char;  { The broadcast message to be printed }
   Len: Signed_Word;            { Length of the broadcast message }

{ This procedure is called Asynchronously when a broadcast message is received.  It will paste a window bearing the message on the
  screen, and wait for the return key to be pressed.  Then normal operation will resume. }

Begin { Message Trap }
   Msg:='';
   SMG$Get_Broadcast_Message (Pasteboard,Msg,Len);          { Get the message }
   Strip_Controls (Msg);

   If Broadcast_On then
      Begin { Broadcast }
         SMG$End_Pasteboard_Update (Pasteboard);
         SMG$Set_Cursor_Mode (Pasteboard, 1);          { Turn off the cursor }

         { Create, initialize, and label the display required by the procedure }

         Create_and_Label (BroadcastDisplay, '> A Message for Thee: <');

         { Print the message to the display }

         SMG$Put_Line (BroadcastDisplay,Msg,wrap_flag:=SMG$M_WRAP_WORD);

         { Past it onto the pasteboard }

         SMG$Paste_Virtual_Display (BroadcastDisplay,Pasteboard,2,2);
         Ring_Bell (BroadcastDisplay);

                { Delete all created virtual devices }

         LIB$WAIT (4.0);

         SMG$Unpaste_Virtual_Display (BroadcastDisplay,Pasteboard);
         SMG$Delete_Virtual_Display (BroadcastDisplay);

         { If the cursor was on before, turn it on again }

         If Cursor_Mode then SMG$Set_Cursor_Mode (Pasteboard, 0);
      End;  { Broadcast }
End;  { Message_Trap }

(******************************************************************************)

[Global]Procedure Printing_Message;
Begin { Printing Message }
    { TODO: Enter this code }
End;  { Printing Message }


[Global]Procedure Closing_Warning (Minutes_Until_Closing: Integer;  Var minutes_Left: Integer);

Begin { Printing Message }
    { TODO: Enter this code }
End;  { Printing Message }
End.  { Windows }
