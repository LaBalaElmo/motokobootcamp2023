export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'get' : IDL.Func([IDL.Text], [IDL.Vec(IDL.Principal)], []),
    'parseControllersFromCanisterStatusErrorIfCallerNotController' : IDL.Func(
        [IDL.Text],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
