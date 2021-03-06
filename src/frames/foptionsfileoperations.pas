{
   Double Commander
   -------------------------------------------------------------------------
   File operations options page

   Copyright (C) 2006-2015 Alexander Koblov (alexx2000@mail.ru)

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

unit fOptionsFileOperations;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Spin, ExtCtrls, KASComboBox, DividerBevel,
  fOptionsFrame;

type

  { TfrmOptionsFileOperations }

  TfrmOptionsFileOperations = class(TOptionsEditor)
    bvlConfirmations: TDividerBevel;
    cbDeleteToTrash: TCheckBox;
    cbDropReadOnlyFlag: TCheckBox;
    cbPartialNameSearch: TCheckBox;
    cbProcessComments: TCheckBox;
    cbRenameSelOnlyName: TCheckBox;
    cbShowCopyTabSelectPanel: TCheckBox;
    cbSkipFileOpError: TCheckBox;
    cbProgressKind: TComboBoxAutoWidth;
    cbCopyConfirmation: TCheckBox;
    cbMoveConfirmation: TCheckBox;
    cbDeleteConfirmation: TCheckBox;
    cbDeleteToTrashConfirmation: TCheckBox;
    cbSearchDefaultTemplate: TComboBoxAutoWidth;
    cmbTypeOfDuplicatedRename: TComboBoxAutoWidth;
    dbTextSearch: TDividerBevel;
    edtBufferSize: TEdit;
    edtHashBufferSize: TEdit;
    gbUserInterface: TGroupBox;
    gbFileSearch: TGroupBox;
    gbExecutingOperations: TGroupBox;
    lblHashBufferSize: TLabel;
    lblTypeOfDuplicatedRename: TLabel;
    lblSearchDefaultTemplate: TLabel;
    lblBufferSize: TLabel;
    lblProgressKind: TLabel;
    lblWipePassNumber: TLabel;
    rbUseMmapInSearch: TRadioButton;
    rbUseStreamInSearch: TRadioButton;
    seWipePassNumber: TSpinEdit;
    procedure cbDeleteToTrashChange(Sender: TObject);
  private
    FLoading: Boolean;
    FLastLoadedOptionSignature: dword;
    procedure FillTemplatesList(ListItems: TStrings);
  protected
    procedure Init; override;
    procedure Load; override;
    function Save: TOptionsEditorSaveFlags; override;
  public
    constructor Create(TheOwner: TComponent); override;
    class function GetIconIndex: Integer; override;
    class function GetTitle: String; override;
    function CanWeClose(var WillNeedUpdateWindowView: boolean): boolean; override;
  end;

implementation

{$R *.lfm}

uses
  uComponentsSignature, fOptions, uShowMsg, DCStrUtils, uGlobs, uLng,
  fOptionsHotkeys;

{ TfrmOptionsFileOperations }

class function TfrmOptionsFileOperations.GetIconIndex: Integer;
begin
  Result := 8;
end;

class function TfrmOptionsFileOperations.GetTitle: String;
begin
  Result := rsOptionsEditorFileOperations;
end;

procedure TfrmOptionsFileOperations.Init;
begin
  FillTemplatesList(cbSearchDefaultTemplate.Items);
  ParseLineToList(rsOptFileOperationsProgressKind, cbProgressKind.Items);
  ParseLineToList(rsOptTypeOfDuplicatedRename, cmbTypeOfDuplicatedRename.Items);
end;

procedure TfrmOptionsFileOperations.cbDeleteToTrashChange(Sender: TObject);
var
  HotkeysEditor: TOptionsEditor;
begin
  if not FLoading then
  begin
    HotkeysEditor := OptionsDialog.GetEditor(TfrmOptionsHotkeys);
    if Assigned(HotkeysEditor) then
      (HotkeysEditor as TfrmOptionsHotkeys).AddDeleteWithShiftHotkey(cbDeleteToTrash.Checked);
  end;
end;

procedure TfrmOptionsFileOperations.FillTemplatesList(ListItems: TStrings);
begin
  gSearchTemplateList.LoadToStringList(ListItems);
  ListItems.Insert(0, rsOptHotkeysNoHotkey);
end;

procedure TfrmOptionsFileOperations.Load;
begin
  FLoading := True;

  edtBufferSize.Text               := IntToStr(gCopyBlockSize div 1024);
  edtHashBufferSize.Text           := IntToStr(gHashBlockSize div 1024);
  cbSkipFileOpError.Checked        := gSkipFileOpError;
  cbDropReadOnlyFlag.Checked       := gDropReadOnlyFlag;
  rbUseMmapInSearch.Checked        := gUseMmapInSearch;
  cbPartialNameSearch.Checked      := gPartialNameSearch;
  seWipePassNumber.Value           := gWipePassNumber;
  cbProcessComments.Checked        := gProcessComments;
  cbShowCopyTabSelectPanel.Checked := gShowCopyTabSelectPanel;
  cbDeleteToTrash.Checked          := gUseTrash;
  cbRenameSelOnlyName.Checked      := gRenameSelOnlyName;

  case gFileOperationsProgressKind of
    fopkSeparateWindow:           cbProgressKind.ItemIndex := 0;
    fopkSeparateWindowMinimized:  cbProgressKind.ItemIndex := 1;
    fopkOperationsPanel:          cbProgressKind.ItemIndex := 2;
  end;

  cbCopyConfirmation.Checked          := focCopy in gFileOperationsConfirmations;
  cbMoveConfirmation.Checked          := focMove in gFileOperationsConfirmations;
  cbDeleteConfirmation.Checked        := focDelete in gFileOperationsConfirmations;
  cbDeleteToTrashConfirmation.Checked := focDeleteToTrash in gFileOperationsConfirmations;
  cmbTypeOfDuplicatedRename.ItemIndex := Integer(gTypeOfDuplicatedRename);

  cbSearchDefaultTemplate.ItemIndex   := cbSearchDefaultTemplate.Items.IndexOf(gSearchDefaultTemplate);
  if cbSearchDefaultTemplate.ItemIndex < 0 then cbSearchDefaultTemplate.ItemIndex := 0;

  FLoading := False;
  FLastLoadedOptionSignature := ComputeSignatureBasedOnComponent(Self, $00000000);
end;

function TfrmOptionsFileOperations.Save: TOptionsEditorSaveFlags;
begin
  Result := [];

  gCopyBlockSize          := StrToIntDef(edtBufferSize.Text, gCopyBlockSize div 1024) * 1024;
  gHashBlockSize          := StrToIntDef(edtHashBufferSize.Text, gHashBlockSize div 1024) * 1024;
  gSkipFileOpError        := cbSkipFileOpError.Checked;
  gDropReadOnlyFlag       := cbDropReadOnlyFlag.Checked;
  gUseMmapInSearch        := rbUseMmapInSearch.Checked;
  gPartialNameSearch      := cbPartialNameSearch.Checked;
  gWipePassNumber         := seWipePassNumber.Value;
  gProcessComments        := cbProcessComments.Checked;
  gShowCopyTabSelectPanel := cbShowCopyTabSelectPanel.Checked;
  gUseTrash               := cbDeleteToTrash.Checked;
  gRenameSelOnlyName      := cbRenameSelOnlyName.Checked;

  case cbProgressKind.ItemIndex of
    0: gFileOperationsProgressKind := fopkSeparateWindow;
    1: gFileOperationsProgressKind := fopkSeparateWindowMinimized;
    2: gFileOperationsProgressKind := fopkOperationsPanel;
  end;

  gFileOperationsConfirmations := [];
  if cbCopyConfirmation.Checked then
    Include(gFileOperationsConfirmations, focCopy);
  if cbMoveConfirmation.Checked then
    Include(gFileOperationsConfirmations, focMove);
  if cbDeleteConfirmation.Checked then
    Include(gFileOperationsConfirmations, focDelete);
  if cbDeleteToTrashConfirmation.Checked then
    Include(gFileOperationsConfirmations, focDeleteToTrash);
  gTypeOfDuplicatedRename := tDuplicatedRename(cmbTypeOfDuplicatedRename.ItemIndex);

  if cbSearchDefaultTemplate.ItemIndex > 0 then
    gSearchDefaultTemplate:= cbSearchDefaultTemplate.Text
  else begin
    gSearchDefaultTemplate:= EmptyStr;
  end;

  FLastLoadedOptionSignature := ComputeSignatureBasedOnComponent(Self, $00000000);
end;

constructor TfrmOptionsFileOperations.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FLoading := False;
end;

function TfrmOptionsFileOperations.CanWeClose(var WillNeedUpdateWindowView: boolean): boolean;
var
  Answer: TMyMsgResult;
begin
  Result := (FLastLoadedOptionSignature = ComputeSignatureBasedOnComponent(Self, $00000000));

  if not Result then
  begin
    ShowOptions(TfrmOptionsFileOperations);
    Answer := MsgBox(rsMsgFileOperationsModifiedWantToSave, [msmbYes, msmbNo, msmbCancel], msmbCancel, msmbCancel);
    case Answer of
      mmrYes:
      begin
        Save;
        Result := True;
      end;

      mmrNo: Result := True;
      else
        Result := False;
    end;
  end;
end;

end.

