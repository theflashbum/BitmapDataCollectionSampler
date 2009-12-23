package com.flashartofwar
{
import com.flashartofwar.BitmapDataCollectionSampler;
import flash.display.BitmapData;


import flash.geom.Point;
import flash.geom.Rectangle;

import org.flexunit.Assert;

/**
	 * @author jessefreeman
	 */
	public class BitmapDataCollectionSamplerTest extends BitmapDataCollectionSampler
	{

		public function BitmapDataCollectionSamplerTest()
		{
            var collection:Array = [];

            for (var i:int; i < 3; i ++)
            {
                // Create dummy images
                collection.push(new BitmapData(300, 100, false, 0x000000));
            }

            super(collection);
            


		}

		[Test]
		public function testFlashTDDProject() : void
		{
			Assert.assertEquals(totalWidth, 300*3);
		}

        [Test]
        public function testMaxHeight():void
        {
            Assert.assertEquals(maxHeight, 100);
        }

        [Test]
        public function test1stCollectionRect():void
        {
            var rect:Rectangle = collectionRects[0];
            Assert.assertEquals(rect.toString(), "(x=0, y=0, w=300, h=100)");

        }

        [Test]
        public function test2ndCollectionRect():void
        {
            var rect:Rectangle = collectionRects[1];
            Assert.assertEquals(rect.toString(), "(x=301, y=0, w=300, h=100)");
        }

        [Test]
        public function test3rdCollectionRect():void
        {
            var rect:Rectangle = collectionRects[2];
            Assert.assertEquals(rect.toString(), "(x=602, y=0, w=300, h=100)");
        }

        [Test]
        public function testCalculateLeftoverForInRangeSample():void
        {
            var leftover:Number = calculateLeftOverValue(0, 200, collectionRects[0]);
            Assert.assertEquals(leftover, 0);
        }

        [Test]
        public function testCalculateLeftoverForOutOfRangeSample():void
        {
            var leftover:Number = calculateLeftOverValue(0, 500, collectionRects[0]);
            Assert.assertEquals(leftover, 200);
        }

        [Test]
        public function testCalculateStartIndex0():void
        {
            Assert.assertEquals(calculateCollectionStartIndex(new Point(0,0)), 0);
        }

        [Test]
        public function testCalculateStartIndex1():void
        {
            Assert.assertEquals(calculateCollectionStartIndex(new Point(320,0)), 1);
        }

        [Test]
        public function testCalculateStartIndex2():void
        {
            Assert.assertEquals(calculateCollectionStartIndex(new Point(900,0)), 2);
        }

        [Test]
        public function testCalculateStartIndexOutOfRange1():void
        {
            Assert.assertEquals(calculateCollectionStartIndex(new Point(-500,0)), -1);
        }

        [Test]
        public function testCalculateStartIndexOutOfRange2():void
        {
            Assert.assertEquals(calculateCollectionStartIndex(new Point(1000,0)), -1);
        }

        [Test]
        public function testCalculateSamplePosition():void
        {
            var sr:Rectangle = new Rectangle(20, 0, 50, 50);
            var sa:Rectangle = new Rectangle(0, 0, 100, 50);

            var point:Point = calculateSamplePosition(sr, sa);
            Assert.assertEquals(point.toString(), "(x=20, y=0)");
        }

        [Test]
        public function testCalculateSamplePosition2():void
        {
            var sr:Rectangle = new Rectangle(150, 0, 100, 50);
            var sa:Rectangle = new Rectangle(100, 0, 100, 50);

            var point:Point = calculateSamplePosition(sr, sa);
            Assert.assertEquals(point.toString(), "(x=50, y=0)");
        }

        [Test]
        public function testExternalSampleRectIsNotModified():void
        {
            var sampleArea:Rectangle = new Rectangle(0,0,500,100);

            sampleBitmapData(sampleArea);

            Assert.assertEquals(sampleArea.toString(), "(x=0, y=0, w=500, h=100)");
        }
        
	}
}
