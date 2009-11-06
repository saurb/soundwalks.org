clc;
clear all;
close all;

%------------------------------%
% 1. Load distances and costs. %
%------------------------------%
disp('Loading data.');

links = csvread('../data/mds/linksfixed.csv');
ids = unique(links(:,1));
nodes = length(ids);

disp('Creating matrices.');

distances = zeros(nodes, nodes);
costs = zeros(nodes, nodes);
second_indices = zeros(nodes, nodes);

for i = 1:nodes
    for j = i:nodes
        row = (i - 1) * nodes + j;
        costs(i, j) = links(row, 3);
        distances(i, j) = links(row, 4);
    end
end

distances = distances + distances';

%----------------------------%
% 2. Output MDS coordinates. %
%----------------------------%
disp('Performing MDS.');

mds = cmdscale(distances);

mds(:, 1) = (mds(:, 1) - min(mds(:, 1))) / (max(mds(:, 1)) - min(mds(:, 1)));
mds(:, 2) = (mds(:, 2) - min(mds(:, 2))) / (max(mds(:, 2)) - min(mds(:, 2)));

figure;
scatterplot(mds(:,1:2));

for i = 1:nodes
    fprintf('%d,%f,%f\n', ids(i), mds(i, 1), mds(i, 2));
end
