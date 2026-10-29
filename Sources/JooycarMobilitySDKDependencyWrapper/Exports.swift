// Empty wrapper target — su única razón de existir es declarar las
// dependencias transitivas (Amplitude*, Lottie, SVGView) que SPM no permite
// expresar en un binaryTarget. El @_exported re-expone el módulo binario
// para que los consumers solo necesiten `import JooycarMobilitySDK`.
@_exported import JooycarMobilitySDK
