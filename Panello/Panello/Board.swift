//
//  Board.swift
//  Panello
//
//  Created by Andrew Roberts on 4/6/17.
//  Copyright © 2017 Andrew Roberts. All rights reserved.
//

import GLKit

enum GameState {
    case RUN
    case PAUSE
    case END
}

class Board {
    
    // -------------------------------------------------------------------
    // MARK: - Static members
    // -------------------------------------------------------------------
    enum BoardState {
        case RUNNING
        case COUNTDOWN
        case WIN
        case GAME_OVER
    }
    
    private var gridMinX: Float = -0.44
    private var gridMinY: Float = -0.903
    private var blockStepWidth: Float = 0.176
    private var blockStepHeight: Float = 0.136
    private var gridHeight: Float = 1.629
    private var gridWidth: Float = 1.06
    private var _blocksOnBoard: Int = 0
    private var _score: Int
    public var score: Int { return _score }
    public var blocksOnBoard: Int { return _blocksOnBoard }
    public var state: BoardState
    private var offset: Float
    private var riseRate: Float
    private var startTime: Double
    private var _linesRaised: Int
    public var linesRaised: Int { return _linesRaised }
    private var isPuzzle: Bool = false
    private var graceTimer: Float = 0
    private var timePassed: Double = 0
    
    static let panicRow: Int = 9
    static let warningRow: Int = 10
    static let topRow: Int = 11
    
    // -------------------------------------------------------------------
    // MARK: - Static functions
    // -------------------------------------------------------------------
    
    // -------------------------------------------------------------------
    // MARK: - Private instance data
    // -------------------------------------------------------------------
    
    private var _buffer: [Block]
    private var _grid: [[Block]]
    
    // -------------------------------------------------------------------
    // MARK: - Public instance data
    // -------------------------------------------------------------------
    
    public var grid: [[Block]] { return _grid }
    
    // --------------------------------------------------------------------
    // MARK: - Constructors
    // --------------------------------------------------------------------
    
    init() {//        0        1        2        3        4        5
        _grid = [ [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 0
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 1
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 2
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 3
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 4
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 5
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 6
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 7
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 8
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 9
                  [ Block(), Block(), Block(), Block(), Block(), Block() ],  // 10
                  [ Block(), Block(), Block(), Block(), Block(), Block() ] ] // 11
        
        _buffer = [ Block(), Block(), Block(), Block(), Block(), Block() ]
        state = .RUNNING
        _score = 0
        _linesRaised = 0
        offset = 0
        riseRate = 0.001
        startTime = CACurrentMediaTime()
        timePassed = 0
    }
    
    // --------------------------------------------------------------------
    // MARK: - Board functions
    // --------------------------------------------------------------------
    
    func update() {
        if (state == .RUNNING) {
            timePassed = CACurrentMediaTime() - startTime
            increaseSpeed()
            _blocksOnBoard = blockCount()
            handleFalling()
            getMatchingHorizontal()
            getMatchingVertical()
            if (!isPuzzle) {
                raiseBoard()
            }
        }
    }
    
    /* Draw the panel */
    func draw() {
        for i: Int in 0 ..< 12 {
            for j: Int in 0 ..< 6 {
                _grid[i][j].panel?.positionX = gridCoordinateForColumn(column: j)
                _grid[i][j].panel?.positionY = gridCoordinateForRow(row: i)
                _grid[i][j].panel?.draw()
            }
        }
    }
    
    func fillRandom() {
        for i: Int in 0 ..< 6 {
            for j: Int in 0 ..< 6 {
                _grid[i][j].panel = Panel(startCoordinateX: (gridMinX + (blockStepWidth * Float(j))), startCoordinateY: (gridMinY + (blockStepHeight * Float(i))))
                _grid[i][j].air = false
            }
        }
    }
    
    func fillBuffer() {
        for i: Int in 0 ..< 6 {
            _buffer[i].panel = Panel(startCoordinateX: (gridMinX + (blockStepWidth * Float(i))), startCoordinateY: gridMinY)
            _buffer[i].air = false
        }
    }
    
    func buildPuzzleBoard(puzzle: Int) {
        isPuzzle = true
        buildBoardFromString(string: PuzzleLibrary.Instance.getPuzzle(atIndex: puzzle))
    }
    
    private func buildBoardFromString(string: String) {
        var strings: [String] = []
        var i: Int = 11
        var j: Int = 0
        string.enumerateLines{ (line, _) -> () in strings.append(line) }
        for s in strings {
            for char in s.characters {
                switch(char) {
                case "a":
                    _grid[i][j].panel = Panel(startCoordinateX: (gridMinX + (blockStepWidth * Float(j))), startCoordinateY: (gridMinY + (blockStepHeight * Float(i))))
                    _grid[i][j].air = false
                    _grid[i][j].panel!.color = Panel.PanelColor.BLUE
                case "b":
                    _grid[i][j].panel = Panel(startCoordinateX: (gridMinX + (blockStepWidth * Float(j))), startCoordinateY: (gridMinY + (blockStepHeight * Float(i))))
                    _grid[i][j].air = false
                    _grid[i][j].panel!.color = Panel.PanelColor.CYAN
                case "c":
                    _grid[i][j].panel = Panel(startCoordinateX: (gridMinX + (blockStepWidth * Float(j))), startCoordinateY: (gridMinY + (blockStepHeight * Float(i))))
                    _grid[i][j].air = false
                    _grid[i][j].panel!.color = Panel.PanelColor.PURPLE
                case "d":
                    _grid[i][j].panel = Panel(startCoordinateX: (gridMinX + (blockStepWidth * Float(j))), startCoordinateY: (gridMinY + (blockStepHeight * Float(i))))
                    _grid[i][j].air = false
                    _grid[i][j].panel!.color = Panel.PanelColor.GREEN
                case "e":
                    _grid[i][j].panel = Panel(startCoordinateX: (gridMinX + (blockStepWidth * Float(j))), startCoordinateY: (gridMinY + (blockStepHeight * Float(i))))
                    _grid[i][j].air = false
                    _grid[i][j].panel!.color = Panel.PanelColor.RED
                case "f":
                    _grid[i][j].panel = Panel(startCoordinateX: (gridMinX + (blockStepWidth * Float(j))), startCoordinateY: (gridMinY + (blockStepHeight * Float(i))))
                    _grid[i][j].air = false
                    _grid[i][j].panel!.color = Panel.PanelColor.YELLOW
                default:
                    _grid[i][j] = _grid[i][j]
                }
                j += 1
            }
            i -= 1
            j = 0
        }
    }
    
    func blockCanSwapLeft(row: Int, column: Int) -> Bool {
        if (column == 0 || _grid[row][column].air) {
            return false
        }
        else {
            let b: Block = _grid[row][column]
            return (((b.air && _grid[row+1][column].air) || !b.air) && b.panel!.state == .NORMAL)
        }
    }
    
    func blockCanSwapRight(row: Int, column: Int) -> Bool {
        if (column == 5 || _grid[row][column].air) {
            return false
        }
        else {
            let b: Block = _grid[row][column]
            return (((b.air && _grid[row+1][column].air) || !b.air) && b.panel!.state == .NORMAL)
        }
    }
    
    func blockCanFall(row: Int, column: Int) -> Bool {
        if (_grid[row][column].air || row == 0 || _grid[row][column].panel!.state != .NORMAL) {
            return false
        }
        else {
            return (_grid[row-1][column].air && _grid[row][column].panel!.state == .NORMAL)
        }
    }
    
    func swapLeft(row: Int, column: Int) {
        swap(block1: &_grid[row][column-1], block2: &_grid[row][column])

    }
    
    func swapRight(row: Int, column: Int) {
        swap(block1: &_grid[row][column], block2: &_grid[row][column+1])
    }
    
    func swap(block1: inout Block, block2: inout Block) {
        let temp: Block = block1
        block1 = block2
        block2 = temp
    }
    
    func clearBlock(block: inout Block) {
        block = Block()
    }
    
    func blockCount() -> Int {
        var count: Int = 0
        for i: Int in 0 ..< 12 {
            for j: Int in 0 ..< 6 {
                if (!_grid[i][j].air) {
                    count += 1
                }
            }
        }
        return count
    }
    
    func handleFalling() {
        for i: Int in 0 ..< 12 {
            for j: Int in 0 ..< 6 {
//                let b: Block = _grid[i][j]
//                if (b.panel?.state == .FLOATING) {
//                    if (
//                }
                
                if (blockCanFall(row: i, column: j)) {
                   // if (b.panel?.falling) {
                    _grid[i-1][j] = _grid[i][j]
                    clearBlock(block: &_grid[i][j])
                    //}
                }
            }
        }
    }
    
    func getMatchingHorizontal() {
        var matched: Int = 1
        var start: Int = -1
        for i: Int in 0 ..< 12 {
            matched = 1
            start = -1
            for j: Int in 0 ..< 5 {
                if (!(_grid[i][j].air && _grid[i][j+1].air) && (_grid[i][j].panel?.color == _grid[i][j+1].panel?.color)) {
                    if (matched == 1 && start == -1) {
                        matched += 1
                        start = j
                    }
                    else {
                        matched += 1
                    }
                }
                else {
                    if (matched >= 3 && start != -1) {
                        handleMatchingHorizontal(row: i, column: start, length: matched)
                    }
                    matched = 1
                    start = -1
                }
            }
            if (matched >= 3 && start != -1) {
                handleMatchingHorizontal(row: i, column: start, length: matched)
            }
        }
    }
    
    func handleMatchingHorizontal(row: Int, column: Int, length: Int) {
        for j in column ..< column + length {
            clearBlock(block: &_grid[row][j])
        }
        _score += 20 * length
    }
    
    func getMatchingVertical() {
        var matched: Int = 1
        var start: Int = -1
        for j: Int in 0 ..< 6 {
            matched = 1
            start = -1
            for i: Int in 0 ..< 10 {
                if (!(_grid[i][j].air && _grid[i+1][j].air) && (_grid[i][j].panel?.color == _grid[i+1][j].panel?.color)) {
                    if (matched == 1 && start == -1) {
                        matched += 1
                        start = i
                    }
                    else {
                        matched += 1
                    }
                }
                else {
                    if (matched >= 3 && start != -1) {
                        handleMatchingVertical(row: start, column: j, length: matched)
                    }
                    matched = 1
                    start = -1
                }
            }
            if (matched >= 3 && start != -1) {
                handleMatchingVertical(row: start, column: j, length: matched)
            }
        }
    }
    
    func handleMatchingVertical(row: Int, column: Int, length: Int) {
        for i in row ..< row + length {
            clearBlock(block: &_grid[i][column])
        }
        _score += 20 * length
    }
    
    func writeBoard() {
        for i: Int in 0 ..< 12 {
            var string: String = ""
            for j: Int in 0 ..< 6 {
                if (_grid[i][j].air) {
                    string += "x "
                }
                else {
                    switch(_grid[i][j].panel!.color){
                    case Panel.PanelColor.RED:
                        string += "R "
                    case Panel.PanelColor.YELLOW:
                        string += "Y "
                    case Panel.PanelColor.GREEN:
                        string += "G "
                    case Panel.PanelColor.CYAN:
                        string += "C "
                    case Panel.PanelColor.BLUE:
                        string += "B "
                    case Panel.PanelColor.PURPLE:
                        string += "P "
                    }
                }
            }
            print("\(string)")
        }
        print("\n\n")
    }
    
    func gridCoordinateForColumn(column: Int) -> Float {
        return (gridMinX + (blockStepWidth * Float(column)))
    }
    
    func gridCoordinateForRow(row: Int) -> Float {
        return (gridMinY + (blockStepHeight * Float(row)) + offset/2)
    }
    
    func raiseBoard() {
        if (offset >= blockStepHeight) {
            raiseBlocks()
            _linesRaised += 1
            offset = 0
        }
        else {
            if (blocksOnTopRow()) {
                graceTimer += 0.003
                if (graceTimer >= blockStepHeight) {
                    state = .GAME_OVER
                }
                offset = 0
            }
            else {
                graceTimer = 0
                offset += riseRate
            }
        }
    }
    
    func blocksOnTopRow() -> Bool {
        for j: Int in 0 ..< 6 {
            if (!_grid[11][j].air) {
                return true
            }
        }
        return false
    }
    
    func raiseBlocks() {
        if (blocksOnTopRow()) {
            state = .GAME_OVER
        }
        else {
            for i: Int in (1...11).reversed() {
                for j: Int in 0 ..< 6 {
                    if(!blocksOnTopRow()) {
                        _grid[i][j] = _grid[i-1][j]
                    }
                }
            }
            _grid[0] = _buffer
            fillBuffer()
        }
    }
    
    func increaseSpeed() {
        if (Int(timePassed) % 5 == 0) {
            riseRate += (riseRate * 0.001)
        }
    }
}
