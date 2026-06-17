import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePropertyNavCubit extends Cubit<int> {
  CreatePropertyNavCubit() : super(0);

  int? targetReturnStep;

  // 1. Chuyển Step bình thường (hoặc nhảy cóc do user chọn)
  void changeStep(int stepIndex) {
    emit(stepIndex);
  }

  // 2. Gọi hàm này khi bấm nút "SỬA" ở Step 4 (index 3)
  void editStep(int stepToEdit) {
    targetReturnStep = state; // Ghi nhớ: "Tao đang ở Step 4 nhé"
    emit(stepToEdit); // Phóng về Step 1 (index 0) để sửa
  }

  // 3. Gọi hàm này ở nút "TIẾP TỤC" của mọi Step
  void nextStep() {
    if (targetReturnStep != null) {
      // Nếu có lệnh quay về -> Bật ngược lại Step 4
      int returnStep = targetReturnStep!;
      targetReturnStep = null; // Xóa trí nhớ
      emit(returnStep);
    } else {
      // Luồng bình thường: Đi tới bước tiếp theo
      emit(state + 1);
    }
  }
}
