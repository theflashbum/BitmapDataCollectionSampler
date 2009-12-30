package {

import com.bit101.components.HSlider;
import com.flashartofwar.BitmapDataCollectionSampler;
import com.flashartofwar.behaviors.EaseScrollBehavior;
import com.flashartofwar.behaviors.MouseScrollBehavior;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;

import net.hires.debug.Stats;

public class BitmapDataCollectionSamplerApp extends Sprite {

    protected var preloadList:Array = ["image1.jpg","image2.jpg","image3.jpg","image4.jpg","image5.jpg","image1.jpg","image2.jpg","image3.jpg","image4.jpg","image5.jpg","image1.jpg"];
    protected static const BASE_URL:String = "images/";
    protected var currentlyLoading:String;
    protected var loader:Loader = new Loader();
    private var gridPreview:BitmapDataCollectionSampler;
    private var scrubber:HSlider;
    private var layers:Array = [];
    protected var previewScale:Number = .25;
    private var previewDisplay:Bitmap;
    protected var sampleArea:Rectangle = new Rectangle(0, 0, 960, 600);
    private var easeScrollBehavior:EaseScrollBehavior;
    private var mouseScrollBehavior:MouseScrollBehavior;
    private var stats:Stats;

    public function BitmapDataCollectionSamplerApp()
    {
        configureStage();
        preload();
    }

    private function configureStage():void {
        this.stage.align = StageAlign.TOP_LEFT;
        this.stage.scaleMode = StageScaleMode.NO_SCALE;
    }

    protected function init():void
    {
        createGridSampler();
        createScrubber();
        addKeyboardListeners();
        createEaseScrollBehavior();
        createMouseScrollBehavior();
        activateLoop();
        createStats();
    }

    private function createStats():void {
        stats = addChild(new Stats({ bg: 0x000000 })) as Stats;
        stats.y = 30;
    }


    private function activateLoop():void {
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(event:Event):void {
        loop();
    }

    private function createEaseScrollBehavior():void {
        easeScrollBehavior = new EaseScrollBehavior(sampleArea, 0);
    }

    private function createMouseScrollBehavior():void {
        mouseScrollBehavior = new MouseScrollBehavior(sampleArea, gridPreview.totalWidth);

        var debugShape:Shape = new Shape();
        addChild(debugShape);

        //mouseScrollBehavior.displayHitRects(debugShape.graphics);
    }


    private function addKeyboardListeners():void {
        addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown)
    }

    private function onKeyDown(event:KeyboardEvent):void {
        switch (event.keyCode) {
            case 39:
                scrubber.value += 1;
                break;
            case 37:
                scrubber.value -= 1;
                break;
        }
        updateDisplayFromScrubber();
    }

    private function createScrubber():void {
        scrubber = new HSlider(this, 0, 0, onSliderValueUpdate);
        scrubber.width = 960;
        scrubber.y = 10;
    }

    protected function updateDisplayFromScrubber():void {


    }

    private function onSliderValueUpdate(event:Event):void {
        updateDisplayFromScrubber();
    }


    private function createGridSampler():void {

        gridPreview = new BitmapDataCollectionSampler(layers);

        previewDisplay = new Bitmap();

        addChild(previewDisplay);


    }

    /**
     * Handles preloading our images. Checks to see how many are left then
     * calls loadNext or compositeImage.
     */
    protected function preload():void
    {
        if (preloadList.length == 0)
        {
            init();
        }
        else
        {
            loadNext();
        }
    }

    /**
     * Loads the next item in the prelaodList
     */
    private function loadNext():void
    {
        currentlyLoading = preloadList.shift();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);

        loader.load(new URLRequest(BASE_URL + currentlyLoading));
    }

    /**
     * Handles onLoad, saves the BitmapData then calls preload
     */
    private function onLoad(event:Event):void
    {
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoad);

        layers.push(Bitmap(event.target.content).bitmapData);

        currentlyLoading = null;

        preload();
    }

    public function loop():void
    {
        mouseScrollBehavior.calculateTargetPos(mouseX, mouseY);

        var percent:Number = scrubber.value / 100;
        var s:Number = gridPreview.totalWidth;
        var t:Number = sampleArea.width;
        easeScrollBehavior.targetX = percent * (s - t);
        //
        easeScrollBehavior.calculateScrollX();
        //
        previewDisplay.bitmapData = gridPreview.sampleBitmapData(sampleArea);
    }

}
}