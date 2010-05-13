package {

import com.bit101.components.HSlider;
import com.bit101.components.InputText;
import com.flashartofwar.BitmapDataCollectionSampler;
import com.flashartofwar.behaviors.EaseScrollBehavior;
import com.flashartofwar.behaviors.MouseScrollBehavior;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TransformGestureEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;

import flash.text.TextField;

import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import net.hires.debug.Stats;

public class BitmapDataCollectionSamplerApp extends Sprite {

    protected var preloadList:Array = ["image1.jpg","image2.jpg","image3.jpg","image4.jpg","image5.jpg","image6.jpg","image7.jpg","image8.jpg","image9.jpg","image10.jpg","image11.jpg","image12.jpg","image13.jpg","image14.jpg","image15.jpg","image16.jpg","image17.jpg","image18.jpg","image19.jpg","image20.jpg","image21.jpg","image22.jpg","image23.jpg","image24.jpg","image25.jpg","image26.jpg","image27.jpg","image28.jpg","image29.jpg"];
    protected static const BASE_URL:String = "/images/";
    protected var currentlyLoading:String;
    protected var loader:Loader = new Loader();
    private var gridPreview:BitmapDataCollectionSampler;
    private var scrubber:HSlider;
    private var layers:Vector.<BitmapData> = new Vector.<BitmapData>();
    protected var previewScale:Number = .25;
    private var previewDisplay:Bitmap;
    protected var sampleArea:Rectangle = new Rectangle(0, 0, 480, 800);
    private var easeScrollBehavior:EaseScrollBehavior;
    private var mouseScrollBehavior:MouseScrollBehavior;
    private var stats:Stats;
    private var isMouseDown:Boolean;
    private var tf:TextField;

    public function BitmapDataCollectionSamplerApp()
    {


        configureStage();
        
        preload();
    }

    private function createDebugLabel():void {
        tf = new TextField();
        tf.width = 480;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.wordWrap = true;
        tf.multiline = true;
        tf.defaultTextFormat = new TextFormat(null,12,0xffffff);
        tf.text = "reader";
        addChild(tf);
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
        fingerTouch();
        //createDebugLabel();
    }

    private function fingerTouch():void
    {
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

        //stage.addEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe);
    }

    private function onSwipe(event:TransformGestureEvent):void {
        tf.text = event.toString();
        scrubber.value += event.offsetX*2;
    }

    private function onMouseDown(event:MouseEvent):void {
        isMouseDown = true;
    }

    private function onMouseUp(event:MouseEvent):void {
        isMouseDown = false;
    }

    private function onMouseMove(event:MouseEvent):void
    {
        if(isMouseDown){

            var percent:Number = event.localX/stage.stageWidth * 100;
            scrubber.value = percent;
        }
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

            //Back Key: 94
            //Menu Key: 95
        }
        updateDisplayFromScrubber();
    }

    private function createScrubber():void {
        scrubber = new HSlider(this, 0, 0, onSliderValueUpdate);
        scrubber.width = 480;
        scrubber.y = 10;
        //scrubber.alpha = 0;
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
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

        loader.load(new URLRequest(BASE_URL + currentlyLoading));
    }

    private function onError(event:*):void {
        tf.text = event.toString();
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