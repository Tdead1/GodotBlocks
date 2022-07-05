extends Node2D
var myPointAmount = 150;
# Bounds: 
const BOUNDS := Vector2(600, 600)
const ORIGIN := Vector2(0,0);
var myPoints: Array = [];
var mySquares : Array = [];
var mySeed = 0;
class Square:
	var myPoints : Array = [];
	var mySize = Vector2();
	var myOrigin = Vector2();
	var myColor : Color;
	func GetFurthestCorner():
		var pointingVector = myPoints[0] - myOrigin;
		if (pointingVector.length() == 0):
			return myOrigin + mySize / 2;
		else:
			var corner = mySize / 2;
			if (pointingVector.x > 0):
				corner.x = myOrigin.x - corner.x;
			else:
				corner.x = myOrigin.x + corner.x;
				
			if (pointingVector.y > 0):
				corner.y = myOrigin.y - corner.y;
			else:
				corner.y = myOrigin.y + corner.y;
				
			return corner;

func GetRandomColor():
	var color := Vector3(randf(), randf(), randf()).normalized();
	return Color(color.x, color.y, color.z);

func Init():
	update();
	mySquares = [];
	mySeed = 3;
	var wholeField = Square.new();
	wholeField.mySize = BOUNDS;
	wholeField.myOrigin = BOUNDS / 2;
	for i in myPointAmount:
		wholeField.myPoints.push_back(Vector2(randf_range(0, BOUNDS.x), randf_range(0, BOUNDS.y)));
	
	var splitX : bool = true;
	var splittedSquares = Split(wholeField, splitX);
	mySquares.push_back(splittedSquares[0]);
	mySquares.push_back(splittedSquares[1]);
	
	var done : bool = false;
	var squaresAmount = mySquares.size();
	var squareCounter = 0;
	while (squareCounter < squaresAmount):
		if (mySquares[squareCounter].myPoints.size() < 2):
			squareCounter = squareCounter + 1;
			continue;
		splitX = mySquares[squareCounter].mySize.x > mySquares[squareCounter].mySize.y;
		var squareToSlice = mySquares.pop_at(squareCounter);
		var splittedSquare = Split(squareToSlice, splitX);
		mySquares.push_back(splittedSquare[0]);
		mySquares.push_back(splittedSquare[1]);
		squaresAmount = mySquares.size();

func _ready():
	Init();

func _process(_delta):
	return;

func _draw():
	for i in mySquares:
		DrawSquare(i);
		DrawPoint(i.myOrigin, 1, GetRandomColor());
		DrawPoint(i.myPoints[0]);
		draw_line(i.myOrigin, i.GetFurthestCorner(), Color(0,1,0), 1);
	
	#draw_colored_polygon(myPoints, GetRandomColor());
	draw_line(Vector2(BOUNDS.x, ORIGIN.x), Vector2(BOUNDS.x, BOUNDS.y), Color(0,0,0), 2);
	return;

static func SortVectorX(a, b):
	return a.x < b.x;
static func SortVectorY(a, b):
	return a.y < b.y;

# Only do this on arrays with more than 1 entry! 
func Split(square : Square, isOverX : bool):
	square.myPoints.sort_custom(SortVectorX if isOverX else SortVectorY);
	var low = Square.new();
	var high = Square.new();
	
	low.myPoints = square.myPoints.slice(0, square.myPoints.size() / 2);
	high.myPoints = square.myPoints.slice(square.myPoints.size() / 2, square.myPoints.size());
	
	var maximum = square.myOrigin + square.mySize / 2;
	var minimum = square.myOrigin - square.mySize / 2;
	var xDivide = (low.myPoints[low.myPoints.size() - 1].x + high.myPoints[0].x) / 2;
	var yDivide = (low.myPoints[low.myPoints.size() - 1].y + high.myPoints[0].y) / 2;
	
	var xLineStart = Vector2(minimum.x, yDivide);
	var xLineEnd = Vector2(maximum.x, yDivide);
	
	var yLineStart = Vector2(xDivide, minimum.y);
	var yLineEnd = Vector2(xDivide, maximum.y);
	
	low.mySize = Vector2(xDivide - minimum.x, yDivide - minimum.y);
	high.mySize = Vector2(maximum.x - xDivide, maximum.y - yDivide);
	
	low.myOrigin = Vector2(xDivide - low.mySize.x / 2, yDivide - low.mySize.y / 2);
	high.myOrigin =Vector2(xDivide + high.mySize.x / 2, yDivide + high.mySize.y / 2);
	
	if isOverX:
		low.mySize.y = square.mySize.y;
		high.mySize.y = square.mySize.y;
		low.myOrigin.y = square.myOrigin.y; 
		high.myOrigin.y = square.myOrigin.y; 
	else:
		low.mySize.x = square.mySize.x;
		high.mySize.x = square.mySize.x;
		low.myOrigin.x = square.myOrigin.x; 
		high.myOrigin.x = square.myOrigin.x; 
	
	low.myColor = GetRandomColor();
	high.myColor = GetRandomColor();
	var squares : Array = [low, high];
	return squares;

func _on_point_amount_changed(new_text):
	if (new_text.is_valid_int()):
		myPointAmount = new_text.to_int();
	return;

func DrawSquare(square : Square):
	draw_rect(Rect2(square.myOrigin - square.mySize / 2, square.mySize), square.myColor, false, 1);
	return;
	
func DrawPoint(location : Vector2, size := 3, color = Color(1, 0, 0)):
	draw_circle(location, size, color);
	return;	

func _on_Reload_pressed():
	Init();
	return;
