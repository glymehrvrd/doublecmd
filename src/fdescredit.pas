{
   Double commander
   -------------------------------------------------------------------------
   Dialog for editing file comments.

   Copyright (C) 2008-2014 Alexander Koblov (alexx2000@mail.ru)

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit fDescrEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Buttons, ActnList, uDescr,
  uFormCommands;

type

  { TfrmDescrEdit }

  TfrmDescrEdit = class(TForm, IFormCommands)
    actSaveDescription: TAction;
    ActionList: TActionList;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    cbEncoding: TComboBox;
    lblFileName: TLabel;
    lblEncoding: TLabel;
    lblEditCommentFor: TLabel;
    memDescr: TMemo;
    procedure actExecute(Sender: TObject);
    procedure cbEncodingChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure memDescrKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FDescr: TDescription;
    FCommands: TFormCommands;
    procedure DisplayEncoding;
    property Commands: TFormCommands read FCommands implements IFormCommands;
  public
    constructor Create(TheOwner: TComponent); override;
  published
    procedure cm_SaveDescription(const Params: array of string);
  end; 

function ShowDescrEditDlg(sFileName: String): Boolean;

implementation

{$R *.lfm}

uses
  LCLType, LConvEncoding, DCStrUtils, uHotkeyManager, uLng, uGlobs;

const
  HotkeysCategory = 'Edit Comment Dialog';

function ShowDescrEditDlg(sFileName: String): Boolean;
const
  nbsp = #194#160;
begin
  Result:= False;
  with TfrmDescrEdit.Create(Application) do
  begin
    FDescr:= TDescription.Create(False);
    lblFileName.Caption:= sFileName;
    // read description
    memDescr.Lines.Text:= StringReplace(FDescr.ReadDescription(sFileName), nbsp, LineEnding, [rfReplaceAll]);
    DisplayEncoding;
    if ShowModal = mrOK then
      begin
        FDescr.WriteDescription(sFileName, StringReplace(memDescr.Lines.Text, LineEnding, nbsp, [rfReplaceAll]));
        FDescr.SaveDescription;
        Result:= True;
      end;
    FDescr.Free;
    Free;
  end;
end;

{ TfrmDescrEdit }

procedure TfrmDescrEdit.FormCreate(Sender: TObject);
var
  HMForm: THMForm;
  Hotkey: THotkey;
begin
  // fill encoding combobox
  cbEncoding.Clear;
  GetSupportedEncodings(cbEncoding.Items);

  HMForm := HotMan.Register(Self, HotkeysCategory);
  Hotkey := HMForm.Hotkeys.FindByCommand('cm_SaveDescription');

  if Assigned(Hotkey) then
    btnOK.Caption := btnOK.Caption + ' (' + ShortcutsToText(Hotkey.Shortcuts) + ')';
end;

procedure TfrmDescrEdit.memDescrKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then ModalResult:= btnCancel.ModalResult;
end;

procedure TfrmDescrEdit.DisplayEncoding;
var
  I: Integer;
begin
  for I:= 0 to cbEncoding.Items.Count - 1 do
    if SameText(NormalizeEncoding(cbEncoding.Items.Strings[I]), FDescr.Encoding) then
      begin
        cbEncoding.ItemIndex:= I;
        Break;
      end;
end;

constructor TfrmDescrEdit.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FCommands := TFormCommands.Create(Self, actionList);
end;

procedure TfrmDescrEdit.cm_SaveDescription(const Params: array of string);
begin
  ModalResult:= btnOK.ModalResult;
end;

procedure TfrmDescrEdit.cbEncodingChange(Sender: TObject);
begin
  FDescr.Encoding:= cbEncoding.Text;
  memDescr.Lines.Text:= FDescr.ReadDescription(lblFileName.Caption);
end;

procedure TfrmDescrEdit.actExecute(Sender: TObject);
var
  cmd: string;
begin
  cmd := (Sender as TAction).Name;
  cmd := 'cm_' + Copy(cmd, 4, Length(cmd) - 3);
  Commands.ExecuteCommand(cmd, []);
end;

initialization
  TFormCommands.RegisterCommandsForm(TfrmDescrEdit, HotkeysCategory, @rsHotkeyCategoryEditCommentDialog);

end.

