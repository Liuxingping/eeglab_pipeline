function EEG = add_online_reference(EEG, online_ref)

switch oneline_ref
  case 'Cz'
    ref = struct('labels',{'Cz'},...
                 'type',{'REF'},...
                 'theta',{172.0305},...
                 'radius',{0.0054779},...
                 'X',{-0.16724},...
                 'Y',{-0.023413},...
                 'Z',{9.8118},...
                 'sph_theta',{-172.0305},...
                 'sph_phi',{89.014},...
                 'sph_radius',{9.8132},...
                 'urchan',{68},...
                 'ref',{''},...
                 'datachan',{0});
  case 'FCz'
    return;
    % TODO
end
EEG = pop_reref( EEG, [], 'refloc', ref );
