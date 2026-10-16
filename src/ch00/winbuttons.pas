{ used by ch14 pattdlg }
{ source: VP os2pmapi  }
{ modified for fpc     }

function WinCheckButton(Dlg: cardinal; id: ULong; CheckState: ULong): ULong; inline;
begin
  WinCheckButton := ulong(WinSendDlgItemMsg(Dlg, id, bm_SetCheck, pointer(CheckState), nil));
end;

function WinQueryButtonCheckstate(hwndDlg : cardinal; id : ULong) : ULong; inline;
begin
  WinQueryButtonCheckstate :=
    ULong( WinSendDlgItemMsg(hwndDlg, id, BM_QUERYCHECK, nil, nil) );
end;

