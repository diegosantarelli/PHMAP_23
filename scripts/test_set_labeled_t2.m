function test_set_labeled_t2 = test_set_labeled_t2()   
    data = readtable('dataset/test/answer.csv');

    data.Name = strcat('Case', string(data.ID));

    test_set_labeled_t2 = data(:, {'Name', 'task2'});

    test_set_labeled_t2(test_set_labeled_t2.task2 == 0, :) = [];

    test_set_labeled_t2.task2(ismember(test_set_labeled_t2.task2, [2, 3])) = 4;

    test_set_labeled_t2 = test_set_labeled_t2;
end
