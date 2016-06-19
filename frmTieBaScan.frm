VERSION 5.00
Begin VB.Form frmTieBaScan 
   Caption         =   "扫描"
   ClientHeight    =   5550
   ClientLeft      =   60
   ClientTop       =   405
   ClientWidth     =   11910
   LinkTopic       =   "Form1"
   ScaleHeight     =   5550
   ScaleWidth      =   11910
   StartUpPosition =   3  '窗口缺省
   Begin VB.CommandButton Command2 
      Caption         =   "配置信息"
      Height          =   495
      Left            =   7920
      TabIndex        =   18
      Top             =   4920
      Width           =   2055
   End
   Begin VB.CommandButton Command1 
      Caption         =   "批量删帖"
      Height          =   495
      Left            =   5640
      TabIndex        =   17
      Top             =   4920
      Width           =   2055
   End
   Begin VB.ListBox lstURL 
      Height          =   4260
      Left            =   5640
      Style           =   1  'Checkbox
      TabIndex        =   1
      Top             =   480
      Width           =   6135
   End
   Begin VB.Frame Frame1 
      Caption         =   "贴吧控制台"
      Height          =   4935
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   5415
      Begin VB.CommandButton btnReadHistory 
         Caption         =   "读取历史记录"
         Height          =   495
         Left            =   2880
         TabIndex        =   16
         Top             =   1560
         Width           =   2415
      End
      Begin VB.TextBox txtPageEnd 
         Height          =   270
         Left            =   4560
         TabIndex        =   14
         Text            =   "10"
         Top             =   600
         Width           =   735
      End
      Begin VB.TextBox txtPageStart 
         Height          =   270
         Left            =   3480
         TabIndex        =   12
         Text            =   "1"
         Top             =   600
         Width           =   615
      End
      Begin VB.TextBox txtKeyWord 
         Height          =   270
         Left            =   3600
         TabIndex        =   10
         Top             =   270
         Width           =   1695
      End
      Begin VB.CommandButton btnScan 
         Caption         =   "扫描"
         Height          =   495
         Left            =   2880
         TabIndex        =   8
         Top             =   960
         Width           =   2415
      End
      Begin VB.CommandButton btnRemove 
         Caption         =   "删除"
         Height          =   400
         Left            =   1440
         TabIndex        =   7
         Top             =   600
         Width           =   1335
      End
      Begin VB.CommandButton btnAdd 
         Caption         =   "增加"
         Height          =   400
         Left            =   120
         TabIndex        =   6
         Top             =   600
         Width           =   1215
      End
      Begin VB.TextBox txtTieBa 
         Height          =   270
         Left            =   840
         TabIndex        =   5
         Top             =   270
         Width           =   1935
      End
      Begin VB.ListBox lstTieBas 
         Height          =   3660
         Left            =   120
         TabIndex        =   3
         Top             =   1080
         Width           =   2655
      End
      Begin VB.Label Label5 
         Caption         =   "到"
         Height          =   255
         Left            =   4200
         TabIndex        =   13
         Top             =   645
         Width           =   375
      End
      Begin VB.Label Label4 
         Caption         =   "页码"
         Height          =   255
         Left            =   2880
         TabIndex        =   11
         Top             =   645
         Width           =   615
      End
      Begin VB.Label Label3 
         Caption         =   "关键词"
         Height          =   255
         Left            =   2880
         TabIndex        =   9
         Top             =   285
         Width           =   735
      End
      Begin VB.Label Label2 
         Caption         =   "新贴吧"
         Height          =   255
         Left            =   120
         TabIndex        =   4
         Top             =   285
         Width           =   735
      End
   End
   Begin VB.Label lblStatus 
      AutoSize        =   -1  'True
      Height          =   180
      Left            =   120
      TabIndex        =   15
      Top             =   5200
      Width           =   90
   End
   Begin VB.Label Label1 
      Caption         =   "网址"
      Height          =   255
      Left            =   5640
      TabIndex        =   2
      Top             =   240
      Width           =   495
   End
End
Attribute VB_Name = "frmTieBaScan"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private res As ADODB.Recordset
Private currentBar As String

'****************** Event Handler ******************

Private Sub btnAdd_Click()
  Dim barName As String
  
  barName = txtTieBa.text
  If barName = "" Then
    MsgBox "请输入贴吧名", , "提示"
    txtTieBa.SetFocus
    Exit Sub
  End If
  
  If eTieba.BarExist(barName) Then
    MsgBox "贴吧已存在", , "提示"
    txtTieBa.text = ""
    txtTieBa.SetFocus
    Exit Sub
  End If

  eTieba.Create barName
  
  lstTieBas.AddItem barName
End Sub

Private Sub btnReadHistory_Click()
  Dim res As ADODB.Recordset
  
  Set ht = Nothing
  Set ht = New CHashTable
  
  Set res = eScanLog.Where("`bar_id` = ?", tb.Item(currentBar))
  
  If res.RecordCount = 0 Then
    eScanLog.Db.ReleaseRecordset res
    Exit Sub
  End If
  
  Do While Not res.EOF
    ht.Item(lstURL.ListCount) = res.fields("url").Value
    lstURL.AddItem res.fields("title").Value
    res.MoveNext
  Loop
  
  eScanLog.Db.ReleaseRecordset res
End Sub

Private Sub btnScan_Click()
  'page:
  'http://tieba.baidu.com/f?kw=%E5%B0%8F%E7%B1%B3&ie=utf-8&pn=50
  Dim i As Long
  Dim maxPage As Long, minPage As Long
  If currentBar = "" Then
    MsgBox "未选择目标贴吧"
    Exit Sub
  End If
  If txtKeyWord.text = "" Then
    MsgBox "请设置关键字"
    txtKeyWord.SetFocus
    Exit Sub
  End If
  If IsNumeric(txtPageStart.text) Then
    minPage = CLng(txtPageStart.text)
  Else
    MsgBox "起始页码不为数字"
    txtPageStart.text = ""
    txtPageStart.SetFocus
    Exit Sub
  End If
  If IsNumeric(txtPageEnd.text) Then
    maxPage = CLng(txtPageEnd.text)
  Else
    MsgBox "终止页码不为数字"
    txtPageEnd.text = ""
    txtPageEnd.SetFocus
    Exit Sub
  End If
  If minPage > maxPage Then
    maxPage = minPage
    minPage = CLng(txtPageEnd.text)
  End If
  If minPage < 1 Then
    MsgBox "最小页码不得小于1"
    txtPageStart.SetFocus
    Exit Sub
  End If
  '清空
  Set ht = Nothing
  Set ht = New CHashTable
  lstURL.Clear
  '开始扫描
  For i = minPage To maxPage
    SetStatus "当前页码：" & i
    Call scanPage(currentBar, txtKeyWord.text, i)
    DoEvents
  Next i
End Sub

Private Sub Command1_Click()

End Sub

Private Sub Form_Load()
  InitForm
  SetWindowPos Me.hwnd, HWND_TOPMOST, 0&, 0&, 0&, 0&, SWP_NOMOVE Or SWP_NOSIZE
End Sub

Private Sub lstTieBas_Click()
  currentBar = lstTieBas.List(lstTieBas.ListIndex)
End Sub

Private Sub lstURL_Click()
  Dim url As String
  url = ht.Item(lstURL.ListIndex)
  OpenWeb url
End Sub
'****************** Methods ******************
Private Sub SetStatus(ByVal description As String)
  lblStatus.Caption = description
End Sub

Private Sub scanPage(ByVal barName As String, ByVal keyword As String, ByVal pageIndex As Long)
  On Error Resume Next
  Dim web As New WebCode
  Dim pageCode As String
  Dim url As String, baseUrl As String
  
  Dim htmlDom As New HTMLDocument
  Dim htmlHrefs As IHTMLElementCollection
  Dim htmlHref As HTMLAnchorElement
  
  Dim i As Long
  
  baseUrl = "http://tieba.baidu.com/"

  url = baseUrl & "f?kw=" & barName & "&ie=utf-8&pn=" & (pageIndex - 1) * 50
  pageCode = web.GetHTMLCode(url, "utf-8")
  htmlDom.body.innerHTML = pageCode

  Set htmlHrefs = htmlDom.getElementsByTagName("a")
  For Each htmlHref In htmlHrefs
    If LCase(htmlHref.className) = "j_th_tit " Then
      If htmlHref.title Like "*" & keyword & "*" Then
        ht.Item(lstURL.ListCount) = baseUrl & htmlHref.pathname
        'save to db
        eScanLog.Create tb.Item(barName), keyword, baseUrl & htmlHref.pathname, htmlHref.title
        lstURL.AddItem htmlHref.title
      End If
    End If
  Next
End Sub

Private Sub InitForm()
  Set res = eTieba.Db.ExecQuery("select `bar_name`,`id` from `tiebas`")
  If res.RecordCount = 0 Then
    eTieba.Db.ReleaseRecordset res
    Exit Sub
  End If
  Do While Not res.EOF
    lstTieBas.AddItem res.fields("bar_name").Value
    tb.Item(res.fields("bar_name").Value) = res.fields("id").Value
    res.MoveNext
  Loop
  eTieba.Db.ReleaseRecordset res
End Sub

'删帖代码
Private Sub DeleteOnePost(ByVal url As String)

End Sub
