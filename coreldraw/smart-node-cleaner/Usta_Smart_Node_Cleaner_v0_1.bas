Option Explicit

' USTA Smart Node Cleaner - experimental v0.1
' CorelDRAW 2018 / VBA
'
' Original selected curve is never modified.
' Every iteration tests removable nodes on duplicates.
' Candidate results are compared against the immutable original.
' The node producing the smallest geometric deviation wins.
'
' Experimental: dense geometric sampling, not AutoReduce.

Private Const DEFAULT_TOLERANCE_MM As Double = 0.01
Private Const SAMPLE_STEP_MM As Double = 0.05
Private Const EPS As Double = 0.0000001

Public Sub UstaSmartNodeCleaner()
    Dim original As Shape
    Dim work As Shape
    Dim toleranceMM As Double
    Dim s As String

    If ActiveDocument Is Nothing Then
        MsgBox "Open a document first.", vbExclamation, "USTA Smart Node Cleaner"
        Exit Sub
    End If

    If ActiveSelectionRange.Count <> 1 Then
        MsgBox "Select exactly one curve object.", vbExclamation, "USTA Smart Node Cleaner"
        Exit Sub
    End If

    Set original = ActiveSelectionRange(1)

    If original.Type <> cdrCurveShape Then
        MsgBox "The selected object must be a Curve.", vbExclamation, "USTA Smart Node Cleaner"
        Exit Sub
    End If

    s = InputBox("Maximum deviation from ORIGINAL, in mm:" & vbCrLf & vbCrLf & _
                 "Start conservatively. Try 0.01 mm.", _
                 "USTA Smart Node Cleaner", CStr(DEFAULT_TOLERANCE_MM))
    If Len(Trim$(s)) = 0 Then Exit Sub
    s = Replace(s, ",", ".")

    On Error GoTo BadTolerance
    toleranceMM = CDbl(s)
    On Error GoTo 0
    If toleranceMM <= 0 Then GoTo BadTolerance

    ActiveDocument.BeginCommandGroup "USTA Smart Node Cleaner"
    Set work = original.Duplicate
    work.Move original.SizeWidth + 10, 0

    Dim originalNodes As Long, finalNodes As Long, removed As Long
    originalNodes = CountNodes(original)

    If originalNodes < 3 Then
        MsgBox "Not enough nodes to simplify.", vbInformation
        GoTo SafeExit
    End If

    removed = GreedyClean(original, work, toleranceMM)
    finalNodes = CountNodes(work)
    work.CreateSelection
    ActiveDocument.EndCommandGroup

    MsgBox "Finished." & vbCrLf & vbCrLf & _
           "Original nodes: " & originalNodes & vbCrLf & _
           "Result nodes:   " & finalNodes & vbCrLf & _
           "Removed:        " & removed & vbCrLf & _
           "Tolerance:      " & Format$(toleranceMM, "0.######") & " mm" & vbCrLf & vbCrLf & _
           "The original object was not modified.", _
           vbInformation, "USTA Smart Node Cleaner"
    Exit Sub

BadTolerance:
    MsgBox "Tolerance must be a positive number.", vbExclamation, "USTA Smart Node Cleaner"
    Exit Sub

SafeExit:
    On Error Resume Next
    ActiveDocument.EndCommandGroup
End Sub

Private Function GreedyClean(ByVal original As Shape, ByVal work As Shape, ByVal toleranceMM As Double) As Long
    Dim removed As Long, keepGoing As Boolean
    removed = 0
    keepGoing = True

    Do While keepGoing
        keepGoing = False

        Dim bestSP As Long, bestNode As Long, bestError As Double
        bestError = 1E+30

        Dim spIndex As Long, nodeIndex As Long, nCount As Long

        For spIndex = 1 To work.Curve.SubPaths.Count
            nCount = work.Curve.SubPaths(spIndex).Nodes.Count

            If nCount > MinimumNodes(work.Curve.SubPaths(spIndex)) Then
                For nodeIndex = 1 To nCount
                    If CanTryNode(work.Curve.SubPaths(spIndex), nodeIndex) Then
                        Dim testShape As Shape, errMM As Double
                        Set testShape = work.Duplicate

                        On Error Resume Next
                        testShape.Curve.SubPaths(spIndex).Nodes(nodeIndex).Delete

                        If Err.Number = 0 Then
                            On Error GoTo 0
                            errMM = ShapeDeviationMM(original, testShape, toleranceMM)

                            If errMM < bestError Then
                                bestError = errMM
                                bestSP = spIndex
                                bestNode = nodeIndex
                            End If
                        Else
                            Err.Clear
                            On Error GoTo 0
                        End If

                        testShape.Delete
                    End If
                Next nodeIndex
            End If
        Next spIndex

        If bestSP > 0 Then
            If bestError <= toleranceMM + EPS Then
                work.Curve.SubPaths(bestSP).Nodes(bestNode).Delete
                removed = removed + 1
                keepGoing = True
                DoEvents
            End If
        End If
    Loop

    GreedyClean = removed
End Function

Private Function ShapeDeviationMM(ByVal original As Shape, ByVal testShape As Shape, ByVal stopAfterMM As Double) As Double
    Dim d1 As Double, d2 As Double

    d1 = DirectionalDeviationMM(original, testShape, stopAfterMM)
    If d1 > stopAfterMM Then
        ShapeDeviationMM = d1
        Exit Function
    End If

    d2 = DirectionalDeviationMM(testShape, original, stopAfterMM)

    If d1 > d2 Then
        ShapeDeviationMM = d1
    Else
        ShapeDeviationMM = d2
    End If
End Function

Private Function DirectionalDeviationMM(ByVal sourceShape As Shape, ByVal targetShape As Shape, ByVal stopAfterMM As Double) As Double
    Dim worst As Double
    Dim sp As SubPath
    worst = 0#

    For Each sp In sourceShape.Curve.SubPaths
        Dim approxLength As Double, samples As Long, i As Long
        approxLength = ApproxSubPathLength(sp)
        samples = CLng(approxLength / SAMPLE_STEP_MM)

        If samples < 20 Then samples = 20
        If samples > 5000 Then samples = 5000

        For i = 0 To samples
            Dim t As Double, x As Double, y As Double, d As Double
            t = (100# * i) / samples
            GetPointAtPercent sp, t, x, y
            d = DistancePointToShapeMM(x, y, targetShape)

            If d > worst Then worst = d
            If worst > stopAfterMM Then
                DirectionalDeviationMM = worst
                Exit Function
            End If
        Next i
    Next sp

    DirectionalDeviationMM = worst
End Function

Private Function DistancePointToShapeMM(ByVal px As Double, ByVal py As Double, ByVal targetShape As Shape) As Double
    Dim best As Double
    Dim sp As SubPath
    best = 1E+30

    For Each sp In targetShape.Curve.SubPaths
        Dim approxLength As Double, samples As Long
        approxLength = ApproxSubPathLength(sp)
        samples = CLng(approxLength / SAMPLE_STEP_MM)

        If samples < 20 Then samples = 20
        If samples > 5000 Then samples = 5000

        Dim prevX As Double, prevY As Double, i As Long
        GetPointAtPercent sp, 0#, prevX, prevY

        For i = 1 To samples
            Dim x As Double, y As Double, d As Double
            GetPointAtPercent sp, (100# * i) / samples, x, y
            d = PointSegmentDistance(px, py, prevX, prevY, x, y)

            If d < best Then best = d
            prevX = x
            prevY = y
        Next i
    Next sp

    DistancePointToShapeMM = best
End Function

Private Function PointSegmentDistance(ByVal px As Double, ByVal py As Double, _
                                      ByVal ax As Double, ByVal ay As Double, _
                                      ByVal bx As Double, ByVal by As Double) As Double
    Dim vx As Double, vy As Double, wx As Double, wy As Double
    vx = bx - ax: vy = by - ay
    wx = px - ax: wy = py - ay

    Dim len2 As Double
    len2 = vx * vx + vy * vy

    If len2 <= EPS Then
        PointSegmentDistance = Sqr((px - ax) ^ 2 + (py - ay) ^ 2)
        Exit Function
    End If

    Dim t As Double
    t = (wx * vx + wy * vy) / len2
    If t < 0# Then t = 0#
    If t > 1# Then t = 1#

    Dim cx As Double, cy As Double
    cx = ax + t * vx
    cy = ay + t * vy

    PointSegmentDistance = Sqr((px - cx) ^ 2 + (py - cy) ^ 2)
End Function

Private Sub GetPointAtPercent(ByVal sp As SubPath, ByVal percent As Double, ByRef x As Double, ByRef y As Double)
    Dim seg As Segment
    Dim offset As Double

    Set seg = sp.GetSegmentAtPoint(percent, offset)
    seg.GetPointPositionAt x, y, offset
End Sub

Private Function ApproxSubPathLength(ByVal sp As SubPath) As Double
    Const COARSE_SAMPLES As Long = 50

    Dim x0 As Double, y0 As Double, x1 As Double, y1 As Double
    Dim total As Double, i As Long

    GetPointAtPercent sp, 0#, x0, y0

    For i = 1 To COARSE_SAMPLES
        GetPointAtPercent sp, (100# * i) / COARSE_SAMPLES, x1, y1
        total = total + Sqr((x1 - x0) ^ 2 + (y1 - y0) ^ 2)
        x0 = x1: y0 = y1
    Next i

    ApproxSubPathLength = total
End Function

Private Function MinimumNodes(ByVal sp As SubPath) As Long
    MinimumNodes = 2
End Function

Private Function CanTryNode(ByVal sp As SubPath, ByVal nodeIndex As Long) As Boolean
    If Not sp.Closed Then
        If nodeIndex = 1 Or nodeIndex = sp.Nodes.Count Then
            CanTryNode = False
            Exit Function
        End If
    End If

    CanTryNode = True
End Function

Private Function CountNodes(ByVal sh As Shape) As Long
    Dim total As Long
    Dim sp As SubPath

    For Each sp In sh.Curve.SubPaths
        total = total + sp.Nodes.Count
    Next sp

    CountNodes = total
End Function
