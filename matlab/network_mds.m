clc;
clear all;
close all;

%------------------------------%
% 1. Load distances and costs. %
%------------------------------%
disp('Loading data.');

links = csvread('../data/mds/linksfixed.csv');
ids = unique(links(:,2));
nodes = length(ids);

disp('Creating matrices.');

distances = zeros(nodes, nodes);
costs = zeros(nodes, nodes);

for i = 1:nodes
    for j = 1:nodes
        row = (i - 1) * nodes + j;
        costs(i, j) = links(row, 3);
        distances(i, j) = links(row, 4);
    end
end

size(distances)

%----------------------------%
% 2. Output MDS coordinates. %
%----------------------------%

disp('Performing MDS.');

mds = cmdscale(distances);

for i = 1:nodes
    fprintf('%d,%f,%f\n', ids(i), mds(i, 1), mds(i, 2));
end
