package com.flashartofwar {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

public class BitmapDataCollectionSampler extends Sprite {

    protected var bitmapDataCollection:Vector.<BitmapData>;
    protected var collectionRects:Vector.<Rectangle>;
    protected var _totalWidth:int = 0;
    protected var _maxHeight:Number = 0;
    protected var collectionTotal:int = 0;
    private var bitmapData:BitmapData;
    protected var copyPixelOffset:Point = new Point();
    protected var directionProp:String = "x";
    protected var inverseDirectionProp:String = "y";
    protected var dimensionProp:String = "width";
    protected var inverseDimensionProp:String = "height";
    private var internalSampleArea:Rectangle;
    private var collectionID:int;
    private var sourceRect:Rectangle;
    private var sourceBitmapData:BitmapData;
    private var leftOver:Number;
    private var sampleAreaX:Number;
    private var point:Point;
    private var calculationPoint:Point = new Point();
    private var difference:Number;
    private var sampleArea:Rectangle;
    private var samplePositionPoint:Point = new Point();
    
    /**
     * This is used to debug the ExplorerCanvas. It is important to
     * remember that all the bitmapData in the collection Array must
     * be the same size. The sampleScale is a percentage of the first
     * item's width.
     *
     * @param collection
     */
    public function BitmapDataCollectionSampler(collection:Vector.<BitmapData>) {
        bitmapDataCollection = collection.slice();
        init();
    }

    public function get totalWidth():int {
        return _totalWidth;
    }

    public function get maxHeight():Number {
        return _maxHeight;
    }

    public function set direction(value:String):void
    {
        if(value == "horizontal")
        {
            directionProp = "x";
            inverseDirectionProp = "y";
            dimensionProp = "width";
            inverseDirectionProp = "height";
        }
    }
    protected function init():void {

        indexCollection();
    }

    protected function indexCollection():void {


        var bitmap:Bitmap;
        var bmd:BitmapData;
        var lastX:Number = 0;
        var lastY:Number = 0;
        var padding:Number = 2;
        var i:int;
        collectionTotal = bitmapDataCollection.length;
        var rect:Rectangle;

        collectionRects = new Vector.<Rectangle>(collectionTotal);


        var lastWidth:Number = 0;
        _totalWidth = 0;
        _maxHeight = 0;

        for (i = 0; i < collectionTotal; ++ i) {
            bmd = bitmapDataCollection[i] as BitmapData;

            // create a rect to represent the BitmapData
            rect = new Rectangle(lastX, 0, bmd.width, bmd.height);
            collectionRects[i] = rect;

            lastX += bmd[dimensionProp] + 1;
            // Save out width information
            lastWidth = bmd[dimensionProp];

            _totalWidth += lastWidth;

            if (bmd[inverseDimensionProp] > maxHeight) {
                _maxHeight = bmd[inverseDimensionProp];
            }
        }

    }

    protected function calculateCollectionStartIndex(sampleCoord:Point):int {

        if (sampleCoord.x < 0)
            return -1;

        var i:int;

        for (i = 0; i < collectionTotal; ++ i)
        {
            if (collectionRects[i].containsPoint(sampleCoord))
            {
                return i;
            }
        }

        return -1;
    }


    public function sampleBitmapData(sampleAreaSrc:Rectangle):BitmapData
    {
        // We clone this so it will not modify the ordinal sampleArea Rectangle that is passed in
        internalSampleArea = sampleAreaSrc.clone();

        //TODO this needs to be optimized?
        bitmapData = new BitmapData(internalSampleArea.width, internalSampleArea.height, false, 0x000000);

        sample(internalSampleArea, bitmapData);

        return bitmapData;
    }



    protected function sample(sampleArea:Rectangle, output:BitmapData, offset:Point = null):void {

        calculationPoint.x = sampleArea.x;
        calculationPoint.y = sampleArea.y;

        collectionID = calculateCollectionStartIndex(calculationPoint);

        if (collectionID != -1)
        {
            sourceRect = collectionRects[collectionID];

            sourceBitmapData = bitmapDataCollection[collectionID];

            leftOver = calculateLeftOverValue(sampleArea[directionProp], sampleArea[dimensionProp], sourceRect);

            sampleAreaX = sampleArea[directionProp];

            if (!offset)
                offset = copyPixelOffset;

            point= calculateSamplePosition(sampleArea, sourceRect);

            sampleArea.x = point.x;
            sampleArea.y = point.y;

            output.copyPixels(sourceBitmapData, sampleArea, offset);

            if (leftOver > 0)
            {
                //TODO look into why this is being created each time?
                offset = new Point(output[dimensionProp] - leftOver, 0);//calculateLeftoverOffset(sampleArea, leftOver);
                var leftOverSampleArea:Rectangle = calculateLeftOverSampleArea(sampleArea, leftOver, sourceRect);

                sample(leftOverSampleArea, output, offset);
            }

        }
    }


    protected function calculateLeftOverValue(offset:Number, sampleWidth:Number, sourceRect:Rectangle):Number {

        difference = (offset + sampleWidth) - (sourceRect[directionProp] + sourceRect[dimensionProp]);

        return (difference < 0) ? 0 : difference;
    }


    protected function calculateLeftoverOffset(sampleArea:Rectangle, leftOver:Number):Point {

        return new Point(sampleArea[dimensionProp] - leftOver, 0);
    }

    protected function calculateLeftOverSampleArea(sampleAreaSRC:Rectangle, leftOver:Number, sourceRect:Rectangle):Rectangle {
        sampleArea = sampleAreaSRC.clone();
        sampleArea[dimensionProp] = leftOver + 1;
        sampleArea[directionProp] = sourceRect[directionProp] + sourceRect[dimensionProp] + 1;

        return sampleArea;
    }

    protected function calculateSamplePosition(sampleRect:Rectangle, sourceArea:Rectangle):Point {
        samplePositionPoint[directionProp] = sampleRect[directionProp] - sourceArea[directionProp];

        return samplePositionPoint;
    }


}
}