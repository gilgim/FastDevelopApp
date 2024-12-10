//
//  TensorFlowManager.swift
//  RememberThis
//
//  Created by gaea on 12/10/24.
//

import TensorFlowLite
import Foundation

import TensorFlowLite

class TensorFlowLiteManager {
    private var interpreter: Interpreter?
    private var inputShape: [Int] = []  // 입력 데이터 크기 추적
    
    /// 모델 초기화
    func loadModel(modelName: String = "model") {
        guard let modelPath = Bundle.main.path(forResource: modelName, ofType: "tflite") else {
            print("모델 경로를 찾을 수 없습니다.")
            return
        }
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter?.allocateTensors()
            
            // 입력 텐서의 크기 확인
            if let inputTensor = try interpreter?.input(at: 0) {
                inputShape = inputTensor.shape.dimensions
                print("입력 텐서 크기: \(inputShape)")
            }
            print("모델 로드 성공: \(modelName)")
        } catch {
            print("모델 로드 실패: \(error.localizedDescription)")
        }
    }
    
    /// Float32 배열을 Data 타입으로 변환
    private func floatArrayToData(_ array: [Float32]) -> Data {
        return array.withUnsafeBufferPointer { Data(buffer: $0) }
    }
    private func dataToFloatArray(_ data: Data) -> [Float32] {
        return data.withUnsafeBytes { pointer in
            Array(pointer.bindMemory(to: Float32.self))
        }
    }
    func train(inputData: [Float32], expectedOutput: Float32, learningRate: Float32 = 0.01) {
        guard let interpreter = interpreter else {
            print("모델이 초기화되지 않았습니다.")
            return
        }
        do {
            // 입력 데이터를 Data 타입으로 변환
            let inputDataAsData = floatArrayToData(inputData)
            
            // 입력 데이터 크기 검증
            guard inputData.count == inputShape.reduce(1, *) else {
                print("입력 데이터 크기가 모델 요구사항과 다릅니다.")
                return
            }
            
            // 입력 데이터를 모델에 복사
            try interpreter.copy(inputDataAsData, toInputAt: 0)
            
            // 모델 실행
            try interpreter.invoke()
            
            // 현재 출력 가져오기
            let outputTensor = try interpreter.output(at: 0)
            let predictedOutput = dataToFloatArray(outputTensor.data).first ?? 0.0
            
            // 손실 계산 (예: Mean Squared Error의 기울기)
            let lossGradient = 2 * (predictedOutput - expectedOutput)
            
            // 기존 가중치 가져오기
            let inputTensor = try interpreter.input(at: 0)
            var weights = dataToFloatArray(inputTensor.data)
            
            // 새로운 가중치 계산 및 업데이트
            for i in 0..<weights.count {
                weights[i] -= learningRate * lossGradient * inputData[i]
            }
            
            // 가중치를 모델에 다시 복사
            let updatedWeightsAsData = floatArrayToData(weights)
            try interpreter.copy(updatedWeightsAsData, toInputAt: 0)
            Task { @MainActor in
                saveWeights(weights: weights)
            }
            print("가중치 업데이트 완료: \(weights)")
        } catch {
            print("학습 실패: \(error.localizedDescription)")
        }
    }
    @MainActor
    func saveWeights(weights: [Float32]) {
        // weights를 Data로 변환
        let data = weights.withUnsafeBufferPointer { Data(buffer: $0) }
        let weightModel = RemeberTensorFlowWeightModel(weight: data)
        RememberThisSwiftDataConfiguration.context.insert(weightModel)
        try? RememberThisSwiftDataConfiguration.context.save()
    }
    /// 추론 수행 (k 값 계산)
    /// (repeatCount, memoryLevelNormalized, ageNormalized, repeatEffect)
    func predictKValue(inputData: [Float32]) -> Float32? {
        guard let interpreter = interpreter else {
            print("모델이 초기화되지 않았습니다.")
            return nil
        }
        do {
            // 입력 데이터를 Data 타입으로 변환
            let inputDataAsData = floatArrayToData(inputData)
            
            // 입력 데이터 크기 검증
            guard inputData.count == inputShape.reduce(1, *) else {
                print("입력 데이터 크기가 모델 요구사항과 다릅니다.")
                return nil
            }
            
            // 입력 데이터를 모델에 복사
            try interpreter.copy(inputDataAsData, toInputAt: 0)
            
            // 모델 실행
            try interpreter.invoke()
            
            // 출력 데이터 가져오기
            let outputTensor = try interpreter.output(at: 0)
            let result = outputTensor.data.toArray(type: Float32.self)[0]
            print("예측된 k 값: \(result)")
            return result
        } catch {
            print("추론 실패: \(error.localizedDescription)")
            return nil
        }
    }
}
