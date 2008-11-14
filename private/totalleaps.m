function [leaps]=totalleaps(dates,option)
%TOTALLEAPS    Returns the accumulated leap seconds for the given dates
%
%    Description: TOTALLEAPS(DATES) returns the total offset in seconds
%     of International Atomic Time (TAI) from UTC time for any UTC date.
%     DATES must be an array of UTC dates in the form [years daysofyear] or
%     [years months daysofmonth].
%
%     TOTALLEAPS(DATES,'SERIAL') takes a serialdate array as input.  Note
%     that this option really is not a good idea as using Matlab's DATENUM
%     will not properly handle UTC times (no leap second support) when
%     converting to a serial date number.  If your time is within a
%     positive leap second, DATENUM (and DATEVEC, DATESTR) will convert the
%     date to the following date thus making the date incorrect.
%
%    Notes:
%     - Offsets are not valid for pre-1972 when UTC was not synced with the
%       TAI second and drift between the two time standards occured.
%
%    Tested on: Matlab r2007b
%
%    Usage:    offset=totalleaps(dates)
%              offset=totalleaps(dates,'serial')
%
%    Examples:
%     Get is the current offset:
%      totalleaps(now,'serial')
%
%    See also: leapsinday, leapseconds

%     Version History:
%        Nov.  1, 2008 - initial version
%        Nov. 10, 2008 - uses GETLEAPS to speed calls up
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Nov. 10, 2008 at 16:05 GMT

% todo:

% check nargin
error(nargchk(1,2,nargin));

% check option
if(nargin==1 || isempty(option))
    option='gregorian';
elseif(~ischar(option) || ~any(strcmpi(option,{'serial' 'gregorian'})))
    error('SAClab:totalleaps:optionBad',...
        'OPTION must be ''serial'' or ''gregorian''!');
end

% require numeric
if(~isnumeric(dates))
    error('SAClab:totalleaps:badInput',...
        'DATES must be a numeric array!');
end

% work by input type
sz=size(dates);
switch lower(option)
    case 'gregorian'
        % require Nx2 or Nx3
        ndates=prod(sz)/sz(2);
        if(~any(sz(2)==[2 3]))
            error('SAClab:totalleaps:badInput',...
                'DATES must be a Nx2 or Nx3 array!');
        end
        
        % clean up input
        dates=fixdates(dates);
        if(sz(2)==2); dates=doy2cal(dates); end
        
        % permute and pass to datenum
        dates=permute(dates,[2 1 3:numel(sz)]);
        dates=datenum(dates(:,:).');
        sz(2)=1;
    case 'serial'
        % integer only
        ndates=prod(sz);
        dates=floor(dates(:));
end

% get leapsecond info
[leapdates,offset]=getleaps();
nleaps=numel(offset);
offset=cumsum([0; offset]);

% expand (to vectorize)
dates=dates(:,ones(1,nleaps));
leapdates=leapdates(:,ones(1,ndates));

% compare dates
leaps=reshape(offset(1+sum(dates>=leapdates.',2)),sz);

end