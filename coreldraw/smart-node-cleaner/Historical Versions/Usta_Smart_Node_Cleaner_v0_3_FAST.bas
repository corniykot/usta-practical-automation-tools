Option Explicit

' USTA Smart Node Cleaner - v0.3 FAST
' CorelDRAW 2018 / VBA
'
' Uses CorelDRAW's native NodeRange.AutoReduce(PrecisionMargin).
' PrecisionMargin is the maximum allowable deviation in document units.
' This macro temporarily switches the document to millimeters so the UI
' tolerance is always entered in mm.
'
' Original is never modified. Result is created as a duplicate.

Private Const DEFAULT_TOLERANCE_MM As Double = 0.01

Public Sub UstaSmartNodeCleaner()

    Dim doc As Document
    Dim original As Shape
    Dim result As Shape
    Dim oldUnit As cdrUnit
    Dim toleranceMM As Double
    Dim s As String
    Dim beforeNodes As Long
    Dim afterNodes As Long
    Dim commandOpen As Boolean

    If ActiveDocument Is Nothing Then
        MsgBox "Open a document first.", vbExclamation, "USTA Smart Node Cleaner"
        Exit Sub
    End If

    Set doc = ActiveDocument

    If ActiveSelectionRange.Count <> 1 Then
        MsgBox "Select exactly one curve object.", vbExclamation, "USTA Smart Node Cleaner"
        Exit Sub
    End If

    Set original = ActiveSelectionRange(1)

    If original.Type <> cdrCurveShape Then
        MsgBox "The selected object must be a Curve.", vbExclamation, "USTA Smart Node Cleaner"
        Exit Sub
    End If

    s = InputBox( _
        "Maximum allowed deviation, in mm:" & vbCrLf & vbCrLf & _
        "Recommended first test: 0.01 mm", _
        "USTA Smart Node Cleaner", _
        CStr(DEFAULT_TOLERANCE_MM))

    If Len(Trim$(s)) = 0 Then Exit Sub

    s = Replace(s, ",", ".")

    If Not IsNumeric(s) Then
        MsgBox "Tolerance must be a positive number.", vbExclamation, "USTA Smart Node Cleaner"
        Exit Sub
    End If

    toleranceMM = Val(s)

    If toleranceMM <= 0 Then
        MsgBox "Tolerance must be a positive number.", vbExclamation, "USTA Smart Node Cleaner"
        Exit Sub
    End If

    On Error GoTo Fail

    oldUnit = doc.Unit
    doc.Unit = cdrMillimeter

    beforeNodes = original.Curve.Nodes.Count

    doc.BeginCommandGroup "USTA Smart Node Cleaner"
    commandOpen = True

    Set result = original.Duplicate

    ' CorelDRAW native simplification.
    ' AutoReduce keeps curve deviation within PrecisionMargin.
    result.Curve.Nodes.All.AutoReduce toleranceMM

    afterNodes = result.Curve.Nodes.Count

    ' Present the result beside the untouched original.
    result.Move original.SizeWidth + 10#, 0#
    result.CreateSelection

    doc.EndCommandGroup
    commandOpen = False
    doc.Unit = oldUnit

    MsgBox _
        "Finished." & vbCrLf & vbCrLf & _
        "Original nodes: " & beforeNodes & vbCrLf & _
        "Result nodes:   " & afterNodes & vbCrLf & _
        "Removed:        " & (beforeNodes - afterNodes) & vbCrLf & _
        "Tolerance:      " & Format$(toleranceMM, "0.######") & " mm" & vbCrLf & vbCrLf & _
        "Original object was not modified.", _
        vbInformation, "USTA Smart Node Cleaner"

    Exit Sub

Fail:
    Dim msg As String
    msg = "Error " & Err.Number & ": " & Err.Description

    On Error Resume Next
    If Not result Is Nothing Then result.Delete
    If commandOpen Then doc.EndCommandGroup
    doc.Unit = oldUnit

    MsgBox msg, vbCritical, "USTA Smart Node Cleaner"

End Sub
