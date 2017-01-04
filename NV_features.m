clear
close all
clc

% Patients
Patient{1} = '23_002';
Patient{2} = '23_003';
Patient{3} = '23_004';
Patient{4} = '23_005';
Patient{5} = '23_006';
Patient{6} = '23_007';

Patient{7} = '24_001';
Patient{8} = '24_002';
Patient{9} = '24_004';
Patient{10} = '24_005';

Patient{11} = '25_001';
Patient{12} = '25_002';
Patient{13} = '25_003';
Patient{14} = '25_004';
Patient{15} = '25_005';

%% colormap


C = {'ca0020','cb0621','cc1022','cc1524','cd1925','ce1d26','cf2228','cf2529','d02729','d12b2b','d12f2c','d2312d','d2332f','d33630','d43831','d43a32','d53d34','d63e35','d74136','d74338','d84539','d8483a','d94a3c','da4c3d','da4e3f','db5040','dc5141','dc5343','dd5544','de5745','de5947','df5b48','df5d4a','e05f4b','e0604c','e1634e','e1644f','e26650','e36852','e36a54','e46b55','e46d57','e56f58','e5705a','e6725b','e7735c','e7765e','e8775f','e87861','e97a63','e97c65','ea7d66','ea8068','eb8169','eb836a','eb846c','ec856d','ec886f','ed8971','ed8b72','ee8c74','ee8e76','ef8f77','ef9279','f0937b','f0947c','f0977e','f1977f','f19982','f19b84','f29d85','f29e87','f2a088','f3a18a','f3a38c','f3a58d','f4a690','f4a891','f4a993','f5ab94','f5ad96','f5ae99','f5b09a','f6b19c','f6b39d','f6b4a0','f7b6a1','f7b8a3','f7b9a6','f7bba7','f7bda9','f8beaa','f8c0ad','f8c2af','f8c3b0','f8c5b3','f9c6b5','f9c8b7','f9c9b8','f9caba','f9cdbd','f9cdbe','f9d0c1','f9d1c3','f9d3c5','f9d4c7','f9d5c8','f9d7cb','f9d9cd','f9dbcf','f9ddd2','f9ddd3','f9e0d6','f9e0d7','f9e2da','f9e4dc','f9e6de','f9e7e1','f9e9e2','f9eae5','f9ece6','f8ede9','f8f0ec','f8f0ee','f8f3f0','f8f4f2','f7f5f5','f7f7f7','f5f6f6','f3f5f6','f1f4f6','eff3f5','edf2f5','ebf1f4','e9f0f3','e7eff3','e5eef2','e4ecf2','e2ecf1','e0eaf1','dee9f0','dde8f0','dbe7ef','d9e7ef','d8e6ee','d6e5ee','d4e3ed','d2e3ed','d1e1ec','cfe0ec','cddfeb','ccdeeb','c9ddea','c8dcea','c6dbe9','c4dae8','c2d8e8','c0d8e7','bfd7e7','bdd5e6','bbd5e6','bad3e5','b8d2e5','b7d2e4','b5d1e4','b4cfe3','b2cee3','b0cee2','aecce2','accbe1','aacae0','a9c9e0','a7c7df','a6c6df','a4c6de','a3c5de','a1c4dd','9fc3dd','9ec1dc','9cc1dc','9bc0db','99bedb','97bdda','96bcd9','94bbd9','92bad8','90b9d7','8fb7d7','8db7d6','8cb5d6','8ab5d5','89b4d5','87b3d4','86b2d4','85b1d3','83afd3','81aed2','80add1','7dacd1','7cabd0','7aaad0','79a8cf','77a8ce','76a7ce','74a6cd','73a5cd','71a4cc','70a3cc','6ea2cb','6da0cb','6b9fca','699ec9','679dc9','659cc8','639bc7','629ac7','6098c6','5f97c6','5d96c5','5c96c5','5a95c4','5894c4','5792c3','5591c2','5491c2','528fc1','508ec1','4f8dc0','4c8cbf','4a8bbf','488abe','4689be','4487bd','4386bc','4186bc','3f84bb','3d84bb','3b82ba','3981ba','3780b9','357fb8','337fb8','317eb7','2e7db7','2c7bb6','2a7ab6','2779b5','2478b4','2277b4','1f76b3','1b75b2','1774b2','1373b1','0b72b1','0571b0'};
% C = {'f62a00','f62e03','f73005','f73409','f8360b','f83a0e','f93b10','f93f13','fa4014','fa4317','fa4619','fb481b','fb4b1e','fc4c1e','fc4e21','fc5023','fd5224','fd5526','fd5627','fe582a','fe5a2c','ff5c2d','ff5e2f','ff6131','ff6333','ff6535','ff6637','ff6939','ff6b3a','ff6c3c','ff6f3e','ff7040','ff7342','ff7544','ff7646','ff7848','ff7a4a','ff7b4b','ff7d4d','ff7f4f','ff8151','ff8352','ff8454','ff8756','ff8958','ff8959','ff8c5b','ff8e5d','ff8e5e','ff9160','ff9262','ff9363','ff9566','ff9667','ff9969','ff9a6b','ff9c6c','ff9d6e','ff9f6f','ffa071','ffa172','ffa475','ffa476','ffa678','ffa879','ffaa7b','ffaa7c','ffad7f','ffad80','ffb082','ffb183','ffb385','ffb486','ffb589','ffb78a','ffb88c','ffb98d','ffbb8e','ffbd91','ffbe92','ffc094','ffc195','ffc297','ffc399','ffc49a','ffc69c','ffc79d','ffc9a0','ffcaa1','ffcca2','ffcea4','ffcea5','ffd0a7','ffd2a9','ffd2aa','ffd4ac','ffd6ae','ffd7af','ffd8b1','ffdab2','ffdbb4','ffddb6','ffddb7','ffdfba','ffe1bb','ffe1bc','ffe4be','ffe5c0','ffe5c1','ffe7c3','ffe8c4','ffe9c6','ffecc8','ffedc9','ffedcb','ffefcd','fff1ce','fff1cf','fff4d2','fff4d3','fff6d4','fff7d7','fff8d8','fff9d9','fffbdc','fffcdd','fffdde','ffffe0','fdfedf','fcfdde','fafbdd','f8fadc','f6f9db','f5f8da','f3f6d9','f1f5d8','f0f4d8','eef2d6','ebf1d5','eaf0d5','e9eed4','e6edd3','e5ebd2','e3ead1','e2e9d0','dfe8cf','dee7ce','dde6cd','dbe4cc','d9e2cb','d7e1ca','d6e0ca','d3dfc8','d2ddc7','d0ddc7','cfdbc6','ccdac4','cbd8c4','cad8c3','c8d6c2','c6d4c1','c4d3c0','c3d2bf','c2d1be','bfcfbd','bdcfbc','bccdbb','baccbb','b8cbb9','b7cab9','b5c8b8','b4c7b7','b1c6b6','b0c4b5','afc3b4','adc2b3','aac1b2','a9c0b1','a8bfb0','a6beb0','a4bcae','a2baad','a1b9ad','9fb8ac','9eb7ab','9bb6aa','9ab5a9','99b4a8','97b2a7','95b1a6','93afa5','92aea4','90aea4','8faca3','8caba2','8ba9a1','89a9a0','88a89f','86a69e','84a49d','82a49c','81a39b','80a19b','7ea09a','7b9f98','7a9d98','799c97','779b96','769a95','739994','729793','709692','6f9592','6d9491','6b9390','69918f','68908e','66908d','658e8c','638d8b','608c8a','5f8b89','5d8a89','5c8988','5a8787','598686','568585','548384','538383','518283','508182','4e7f81','4b7e80','4a7d7f','487c7e','467a7d','457a7d','43787c','41777b','3e767a','3c7579','3b7378','397277','377177','367176','346f75','306e74','2e6c73','2c6b72','2a6a71','286a70','266970','24676f','22666e','1e656d'};
C = fliplr(C);
C2 = hex2rgb(C);

cmap = C2;

%%

A = getCustomAxesPos(3,3,0.1,0.1);
A = A';
A = A(:);
delete(A(8:9));

font = 'arial';
fsize = 8;

topFeatureGroup = zeros(7,5);
%%
ind = 1;
for iPt = 1:15
    
    curPt = Patient{iPt};
    
    filename = [curPt '_Features.mat'];
    if ~exist(filename,'file');
        continue;
    end
    
    load(filename);
    
    [~,bestFeatures] = sort(rankFeatures,2);
    bestFeatures = bestFeatures(:,1:16);
    
    groupFeature = floor(bestFeatures/16);
    bestChans = mod(bestFeatures,16);
    bestChans(bestChans == 0) = 16;
    bestChans = bestChans(:);
    chanCount = histcounts(bestChans,1:17);
    chanCount = reshape(chanCount,4,4);
    
    topFeatureGroup(ind,:) = histcounts(groupFeature,0:5);
   
    M = median(rankFeatures);
    [~,I] = sort(M);
    
    % plot features rank
    axes(A(ind));
    for n = 1:10
        plot(rankFeatures(n,I),'k.'); hold on;
    end
%     boxplot(rankFeatures(:,I),'colors','k', 'boxstyle','filled', ...
%         'medianstyle','line',...
%         'outliersize',6,'symbol','k.');
    hold on;
    line([1 80],[16 16],'color','r','linewidth',1.5)
    
    set(gca,'box','off','xtick',[],'ytick',[],'fontname',font,'fontsize',fsize);
    
    temp = figure;
    imagesc(chanCount); colormap(cmap);
    set(gca,'visible','off');
    set(temp,'paperunits','centimeters','paperposition',[0 0 2 2]);
    print(temp,[curPt 'Ch'],'-dpng');
    close(temp);
    
    ind = ind + 1;
end

    set(gcf,'paperunits','centimeters','paperposition',[0 0 12 10]);
    print(gcf,'featureStability','-dpng');