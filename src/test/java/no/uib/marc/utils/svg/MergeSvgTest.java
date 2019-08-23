package no.uib.marc.utils.svg;

import java.util.ArrayList;

/**
 *
 * @author Marc Vaudel
 */
public class MergeSvgTest {
    
    public void testMergeSvg() {
        
        MergeSvg mergeSvg = new MergeSvg();
        
          String svgFilePath = "resources/svg/test_merge.svg";
        
        ArrayList<String> svgFilePaths = new ArrayList<String>(2);
        svgFilePaths.add("resources/svg/FigS1_background.svg");
        svgFilePaths.add("resources/svg/FigS1_7.svg");
        
        mergeSvg.mergeSvgs(svgFilePath, svgFilePaths);
        
    }

}
