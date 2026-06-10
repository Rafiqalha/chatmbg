import { CreateMLCEngine, InitProgressCallback, MLCEngine } from "@mlc-ai/web-llm";

let engineInstance: MLCEngine | null = null;
let isInitializing = false;
let initPromise: Promise<MLCEngine> | null = null;

export const SELECTED_MODEL = "Llama-3.2-1B-Instruct-q4f32_1-MLC";

export async function getWebLLMEngine(
  initProgressCallback?: InitProgressCallback
): Promise<MLCEngine> {
  if (engineInstance) {
    if (initProgressCallback) {
      initProgressCallback({ progress: 1, text: "Model loaded.", timeElapsed: 0 });
    }
    return engineInstance;
  }

  if (isInitializing && initPromise) {
    return initPromise;
  }

  isInitializing = true;
  initPromise = CreateMLCEngine(SELECTED_MODEL, { 
    initProgressCallback: (progress) => {
      console.log(progress.text);
      if (initProgressCallback) {
        initProgressCallback(progress);
      }
    }
  }).then((engine) => {
    engineInstance = engine;
    isInitializing = false;
    return engine;
  });

  return initPromise;
}
