const studyGroupSizeOptions = [10, 20, 30, 40, 50, 100];
const defaultStudyGroupSize = 50;

bool isAllowedStudyGroupSize(int value) =>
    studyGroupSizeOptions.contains(value);
