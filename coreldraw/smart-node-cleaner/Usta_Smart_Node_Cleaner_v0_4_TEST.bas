Attribute VB_Name = "UstaSmartNodeCleanerV04"
Option Explicit

' USTA Smart Node Cleaner v0.4 TEST
' CorelDRAW 2018. Keeps the source intact.
' Native reduction plus conservative removal of nearly collinear nodes.
' This is an experimental heuristic, not a certified maximum-deviation solver.

Private Const DEFAULT_MM As Double = 0.05
Private Const MAX_TESTS As Long = 1500

Public Sub UstaSmartNodeCleanerV04()
    Dim doc As Document, src As Shape, dst As Shape
    Dim oldUnit As cdrUnit, mm As Double, answer As String
    Dim n0 As Long, n1 As Long, n2 As Long, tests As Long
    Dim groupOpen As Boolean, unitChanged As Boolean
    Dim sp As SubPath, i As Long, pass As Long
    Dim x0 As Double, y0 As Double, x1 As Double, y1 As Double
    Dim x2 As Double, y2 As Double, deviation As Double
    Dim removed As Boolean, p As Long

    If ActiveDocument Is Nothing Then
        MsgBox "Open a document first.", vbExclamation
        Exit Sub
    End If
    Set doc = ActiveDocument
    If ActiveSelectionRange.Count <> 1 Then
        MsgBox "Select exactly one curve.", vbExclamation
        Exit Sub
    End If
    Set src = ActiveSelectionRange(1)
    If src.Type <> cdrCurveShape Then
        MsgBox "Select a curve object (Ctrl+Q).", vbExclamation
        Exit Sub
    End If

    answer = InputBox("Tolerance in millimeters (experimental):", _
                      "USTA Smart Node Cleaner v0.4 TEST", CStr(DEFAULT_MM))
    If Len(Trim$(answer)) = 0 Then Exit Sub
    answer = Replace(answer, ",", ".")
    mm = Val(answer)
    If mm <= 0 Or mm > 10 Then
        MsgBox "Enter a tolerance above 0 and at most 10 mm.", vbExclamation
        Exit Sub
    End If

    On Error GoTo Failed
    oldUnit = doc.Unit
    doc.Unit = cdrMillimeter
    unitChanged = True
    n0 = src.Curve.Nodes.Count
    doc.BeginCommandGroup "USTA Smart Node Cleaner v0.4 TEST"
    groupOpen = True
    Set dst = src.Duplicate
    dst.Curve.Nodes.All.AutoReduce mm
    n1 = dst.Curve.Nodes.Count

    ' Only remove nodes that lie extremely close to the chord between
    ' their immediate neighbors. This is deliberately stricter than mm.
    ' Each subpath is handled separately. Endpoints of open paths are kept.
    For pass = 1 To 3
        removed = False
        For p = 1 To dst.Curve.SubPaths.Count
            Set sp = dst.Curve.SubPaths(p)
            i = 2
            Do While i < sp.Nodes.Count
                If tests >= MAX_TESTS Then Exit For
                tests = tests + 1
                If sp.Nodes.Count < 4 Then Exit Do

                x0 = sp.Nodes(i - 1).PositionX
                y0 = sp.Nodes(i - 1).PositionY
                x1 = sp.Nodes(i).PositionX
                y1 = sp.Nodes(i).PositionY
                x2 = sp.Nodes(i + 1).PositionX
                y2 = sp.Nodes(i + 1).PositionY

                deviation = DistanceToSegment(x1, y1, x0, y0, x2, y2)
                If deviation <= mm * 0.05 Then
                    ' Only try if both adjacent segments are straight.
                    ' Curved segments are deliberately left untouched.
                    If sp.Nodes(i - 1).NextSegment.Type = cdrLineSegment And _
                       sp.Nodes(i).NextSegment.Type = cdrLineSegment Then
                        sp.Nodes(i).Delete
                        removed = True
                        ' Stay at the same index to examine the new neighbor.
                    Else
                        i = i + 1
                    End If
                Else
                    i = i + 1
                End If
            Loop
            If tests >= MAX_TESTS Then Exit For
        Next p
        If Not removed Or tests >= MAX_TESTS Then Exit For
    Next pass

    n2 = dst.Curve.Nodes.Count
    dst.Move src.SizeWidth + 10#, 0#
    dst.CreateSelection
    doc.EndCommandGroup
    groupOpen = False
    doc.Unit = oldUnit
    unitChanged = False

    MsgBox "v0.4 TEST completed." & vbCrLf & vbCrLf & _
           "Original: " & n0 & vbCrLf & _
           "After AutoReduce: " & n1 & vbCrLf & _
           "After straight-line pass: " & n2 & vbCrLf & _
           "Additional removed: " & (n1 - n2) & vbCrLf & _
           "Candidates checked: " & tests & vbCrLf & vbCrLf & _
           "Original unchanged. Compare contours carefully.", _
           vbInformation, "USTA Smart Node Cleaner"
    Exit Sub
Failed:
    Dim errText As String
    errText = "Error " & Err.Number & ": " & Err.Description
    On Error Resume Next
    If Not dst Is Nothing Then dst.Delete
    If groupOpen Then doc.EndCommandGroup
    If unitChanged Then doc.Unit = oldUnit
    MsgBox errText, vbCritical, "USTA Smart Node Cleaner v0.4 TEST"
End Sub

Private Function DistanceToSegment(ByVal px As Double, ByVal py As Double, _
    ByVal ax As Double, ByVal ay As Double, ByVal bx As Double, ByVal by As Double) As Double
    Dim dx As Double, dy As Double, t As Double, lengthSquared As Double
    dx = bx - ax: dy = by - ay
    lengthSquared = dx * dx + dy * dy
    If lengthSquared <= 0.000000000001 Then
        DistanceToSegment = Sqr((px - ax) ^ 2 + (py - ay) ^ 2)
        Exit Function
    End If
    t = ((px - ax) * dx + (py - ay) * dy) / lengthSquared
    If t < 0 Then t = 0
    If t > 1 Then t = 1
    DistanceToSegment = Sqr((px - ax - t * dx) ^ 2 + (py - ay - t * dy) ^ 2)
End Function
