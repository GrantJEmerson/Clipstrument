/*:
 # Clipstrument

 ## What is Clipstrument? 🤷‍♂️
 
 **Clipstrument** is a musical instrument that allows for the playback, looping, and manipulation of short audio samples from animated films from the **public domain** in sync with their respective video clips.

 ## How to Use Clipstrument  🎬🎶
 
 Clipstrument’s main interface is a 4x4 sample pad controller which is divided into 4 sections: vocals, bass, chords, and drums. Each sample pad has a thumbnail as its background which shows which video clip it corresponds to. Upon tapping and holding one of the sample pads, the associated audio sample will begin looping and will continue to do so until it is released. While the audio is playing the corresponding video clip from the film will play in the television in the upper right section of the screen. One sample from each of the 4 sections can be played simultaneously. The television will animate to make room for the additional videos. Additionally, the pitch of each sample can be lowered or raised in realtime by dragging down or up on the sample pad while the sample is playing. The audio sample can be further manipulated using the effects controls in the lower right-hand corner. The first three knobs correspond to the audio effects of reverb, delay, and distortion. These knobs control how much of each effect is present in the final output (ie. 100% distortion corresponds to a fully distorted signal). The last knob controls the cutoff frequency of a low pass filter which limits the amount of high-frequency content present in the final output. Lower hertz values correspond to less high frequencies in the output signal. Lastly, on the top of the screen, there are two buttons that change the selected film and three recording controls. The first recording control starts and stops a recording. If it is tapped after already recording a track, it will overdub the existing recording by mixing it with the new audio. The second starts and stops the playback loop of the current recording. The last button clears the current recording. Both the clear and playback controls are disabled before a recording is made.

 To start making music with Clipstrument tap the "Run My Code" button and wait for the live view to expand to the full width of the screen.
 
 I hope you have an awesome time jamming out on Clipstrument! ✌️

 ## Source Attributions
 
 * All film clips and their corresponding audio samples that are used in Clipstrument are from the public domain.
     * Gulliver’s Travels. Dir. Dave Fleischer. Fleischer Studios,  1939. Film.
     * Doggone Tired. Dir. Tex Avery. MGM Cartoons, 1949. Film.
     * Me Musical Nephews. Dir. Seymour Kneitel. Famous Studios, 1942. Film.
 
*/

//#-hidden-code

import PlaygroundSupport
import Book

let page = PlaygroundPage.current
let mainVC = MainViewController()
page.wantsFullScreenLiveView = true
page.liveView = mainVC

//#-end-hidden-code
