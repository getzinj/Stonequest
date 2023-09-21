Module Place_Stack;

{ This module keeps track of where the party has been by pushing the place onto a hybrid stack-queue }

Type
   Horizontal_Type = 0..20;
   Vertical_Type   = 0..19;

   Place_Ptr    = ^Place_Node;
   Place_Node   = Record
                     PosX,PosY: Horizontal_Type;
                     PosZ: Vertical_Type;
                     Next: Place_Ptr;
                  End;
   Place_Stack  = Record
                     Front: Place_Ptr;
                     Length: Integer;
                  End;

(*******************************************************************************)

[Global]Function Empty_Stacks (Stack: Place_Stack): Boolean;

{ This function returns TRUE if there are no nodes on the STACK, and FALSE
  otherwise }

Begin { Empty Stack }
   Empty_Stack:=(Stack.Front=Nil) or (Stack.Length=0);
End;  { Empty Stack }

(*******************************************************************************)

[Global]Procedure Init_Stack (Var Stack: Place_Stack);

Begin { Init Stack }
    Stack.Front:=Nil;   Stack.Length:=0;
End;  { Init Stack }

(*******************************************************************************)

[Global]Procedure Remove_Nodes (Var Stack: Place_Stack);

{ This procedure will remove all the nodes from the STACK, and delete them, returning
  an empty STACK. }

Var
   Temp: Place_Ptr;

Begin { Remove Node }
    While Not Empty_Stack(Stack) do
       Begin
          Temp:=Stack.Front;
          Stack.Front:=Stack.Front^.Next;
          Dispose(Temp);
       End;
    Stack.Front:=Nil;
    Stack.Length:=0;
End;  { Remove Nodes }

(*******************************************************************************)

