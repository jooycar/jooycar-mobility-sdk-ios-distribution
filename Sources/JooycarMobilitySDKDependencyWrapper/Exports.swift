// Empty wrapper target — su única razón de existir es declarar las
// dependencias transitivas (DriveKit, Amplitude*) que SPM no permite
// expresar en un binaryTarget. El @_exported re-expone el módulo binario
// para que los consumers solo necesiten `import JooycarMobilitySDK`.
@_exported import JooycarMobilitySDK
