Option Explicit

' USTA Smart Node Cleaner v0.8 candidate - CorelDRAW 2018
' UserForm UI; algorithm based on v0.6 stable baseline.
' Global two-sided sampled distance to the untouched source subpath.
' Sampled approximation, not an exact Hausdorff bound.
' Replaces selected shape in place. Ctrl+Z restores original.

Private Const MAX_ALLOWED_TRIALS As Long = 4096
Private Const MAX_PASSES As Long = 16
Private Const SAMPLES As Long = 16

Public Sub UstaSmartNodeCleanerV08()
    frmUSTANodeCleaner.Show
End Sub

Public Sub UstaCleanRun(ByVal tol As Double, ByVal maxTrials As Long)
    Dim d As Document, src As Shape, dst As Shape, trial As Shape
    Dim oldUnit As cdrUnit, unitSet As Boolean, cmd As Boolean
    Dim before As Long, nativeCount As Long
    Dim tierMessage As String, choice As VbMsgBoxResult
    Dim p As Long, i As Long, trials As Long, accepted As Long
    Dim pass As Long, passAccepted As Long, passesRun As Long
    Dim a() As Double, b() As Double, deviation As Double
    Dim sp As SubPath, tsp As SubPath
    Dim n As Long, failed As String

    If ActiveDocument Is Nothing Then MsgBox "Open a document.": Exit Sub
    Set d = ActiveDocument
    If ActiveSelectionRange.Count <> 1 Then MsgBox "Select one curve object.": Exit Sub
    Set src = ActiveSelectionRange(1)
    If src.Type <> cdrCurveShape Then MsgBox "Select a curve object.": Exit Sub

    If tol <= 0 Or tol > 2 Then MsgBox "Tolerance must be greater than 0 and at most 2 mm.": Exit Sub
    If maxTrials < 128 Or maxTrials > MAX_ALLOWED_TRIALS Then MsgBox "Attempts must be 128-4096.": Exit Sub

    Select Case maxTrials
        Case 128 To 512
            tierMessage = "Quick cleanup for simple logos."
        Case 513 To 1024
            tierMessage = "Medium workload. Processing time depends on geometry."
        Case 1025 To 2048
            tierMessage = "Serious work. Time for a coffee."
        Case Else
            tierMessage = "Heavy workload. For complex artwork, split it into smaller objects."
    End Select
    If maxTrials >= 1025 Then
        choice = MsgBox("Attempts: " & maxTrials & " / 4096" & vbCrLf & _
            tierMessage & vbCrLf & vbCrLf & _
            "Processing time depends on geometry." & vbCrLf & _
            "Start processing?", vbOKCancel + vbExclamation, "USTA Cleaner v0.7")
        If choice <> vbOK Then Exit Sub
    End If

    On Error GoTo Failure
    oldUnit = d.Unit
    d.Unit = cdrMillimeter
    unitSet = True
    before = src.Curve.Nodes.Count
    d.BeginCommandGroup "USTA Cleaner v0.7"
    cmd = True
    Set dst = src.Duplicate
    ' Native pass disabled: accepted candidates compared to untouched original.
    nativeCount = dst.Curve.Nodes.Count

    For pass = 1 To MAX_PASSES
        passAccepted = 0
        passesRun = pass
        For p = dst.Curve.SubPaths.Count To 1 Step -1
            Set sp = dst.Curve.SubPaths(p)
            If sp.Nodes.Count >= 4 Then
                ' Closed paths have no privileged first/last node.
                ' Open paths must keep their two endpoints.
                If sp.Closed Then
                    i = sp.Nodes.Count
                Else
                    i = sp.Nodes.Count - 1
                End If
                Do While i >= 1 And trials < maxTrials
                    Set sp = dst.Curve.SubPaths(p)
                    n = sp.Nodes.Count
                    If n < 4 Then Exit Do
                    If Not sp.Closed And (i = 1 Or i = n) Then
                        i = i - 1
                    Else
                        trials = trials + 1
                        SamplePath src.Curve.SubPaths(p), a
                        Set trial = dst.Duplicate
                        Set tsp = trial.Curve.SubPaths(p)
                        tsp.Nodes(i).Delete
                        ' Never accept a candidate that changes open/closed topology.
                        If tsp.Closed <> sp.Closed Then
                            trial.Delete
                            Set trial = Nothing
                        Else
                            SamplePath tsp, b
                            deviation = TwoWayDeviation(a, b)
                            If deviation <= tol Then
                                dst.Delete
                                Set dst = trial
                                Set trial = Nothing
                                accepted = accepted + 1
                                passAccepted = passAccepted + 1
                            Else
                                trial.Delete
                                Set trial = Nothing
                            End If
                        End If
                        i = i - 1
                    End If
                Loop
            End If
            If trials >= maxTrials Then Exit For
        Next p
        If passAccepted = 0 Or trials >= maxTrials Then Exit For
    Next pass

    ' In-place replacement, one Ctrl+Z command group.
    src.Delete
    Set src = Nothing
    dst.CreateSelection
    d.EndCommandGroup
    cmd = False
    d.Unit = oldUnit
    unitSet = False
    MsgBox "Cleanup complete." & vbCrLf & _
        "Nodes removed: " & accepted & vbCrLf & vbCrLf & _
        "Before: " & before & " nodes" & vbCrLf & _
        "After: " & dst.Curve.Nodes.Count & " nodes" & vbCrLf & vbCrLf & _
        "Attempts: " & trials & " / " & maxTrials & vbCrLf & _
        "Tolerance: " & tol & " mm" & vbCrLf & vbCrLf & _
        "Ctrl+Z to undo.", vbInformation, "USTA Smart Node Cleaner"
    Exit Sub
Failure:
    failed = "Error " & Err.Number & ": " & Err.Description
    On Error Resume Next
    If Not trial Is Nothing Then trial.Delete
    If Not dst Is Nothing Then dst.Delete
    If cmd Then d.EndCommandGroup
    If unitSet Then d.Unit = oldUnit
    MsgBox failed, vbCritical, "USTA v0.7"
End Sub

Private Sub SamplePath(ByVal sp As SubPath, ByRef xy() As Double)
    Dim j As Long, k As Long, countSeg As Long, idx As Long
    Dim x As Double, y As Double, countPts As Long
    countSeg = sp.Segments.Count
    countPts = countSeg * SAMPLES + 1
    ReDim xy(0 To countPts - 1, 0 To 1)
    idx = 0
    For j = 1 To countSeg
        For k = 0 To SAMPLES - 1
            sp.Segments(j).GetPointPositionAt x, y, CDbl(k) / SAMPLES, cdrParamSegmentOffset
            xy(idx, 0) = x: xy(idx, 1) = y
            idx = idx + 1
        Next k
    Next j
    sp.Segments(countSeg).GetPointPositionAt x, y, 1#, cdrParamSegmentOffset
    xy(idx, 0) = x: xy(idx, 1) = y
End Sub

Private Function TwoWayDeviation(ByRef a() As Double, ByRef b() As Double) As Double
    Dim i As Long, j As Long, best As Double, dist As Double, worst As Double
    For i = LBound(a, 1) To UBound(a, 1)
        best = 1E+30
        For j = LBound(b, 1) To UBound(b, 1) - 1
            dist = PointSegmentDistance(a(i, 0), a(i, 1), b(j, 0), b(j, 1), b(j + 1, 0), b(j + 1, 1))
            If dist < best Then best = dist
        Next j
        If best > worst Then worst = best
    Next i
    For i = LBound(b, 1) To UBound(b, 1)
        best = 1E+30
        For j = LBound(a, 1) To UBound(a, 1) - 1
            dist = PointSegmentDistance(b(i, 0), b(i, 1), a(j, 0), a(j, 1), a(j + 1, 0), a(j + 1, 1))
            If dist < best Then best = dist
        Next j
        If best > worst Then worst = best
    Next i
    TwoWayDeviation = worst
End Function

Private Function PointSegmentDistance(ByVal px As Double, ByVal py As Double, _
    ByVal ax As Double, ByVal ay As Double, ByVal bx As Double, ByVal by As Double) As Double
    Dim dx As Double, dy As Double, t As Double, len2 As Double
    dx = bx - ax: dy = by - ay: len2 = dx * dx + dy * dy
    If len2 > 0 Then
        t = ((px - ax) * dx + (py - ay) * dy) / len2
        If t < 0 Then t = 0
        If t > 1 Then t = 1
    End If
    PointSegmentDistance = Sqr((px - ax - t * dx) ^ 2 + (py - ay - t * dy) ^ 2)
End Function
